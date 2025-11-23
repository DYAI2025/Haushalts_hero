//
//  ChallengeViewModel.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for the challenge flow
@MainActor
class ChallengeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedCategory: ChallengeCategory?
    @Published var beforeImage: UIImage?
    @Published var afterImage: UIImage?
    @Published var currentScore: ExplainableScore?
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?

    // Flow state
    @Published var flowState: FlowState = .categorySelection

    // MARK: - Dependencies

    private let repository: AppRepository
    private let scoringEngine: ScoringEngine
    private let audioManager = AudioManager.shared

    // MARK: - Initialization

    init(repository: AppRepository, scoringEngine: ScoringEngine = ScoringEngine()) {
        self.repository = repository
        self.scoringEngine = scoringEngine
    }

    // MARK: - Flow States

    enum FlowState {
        case categorySelection
        case beforePhoto
        case afterPhoto
        case processing
        case result
    }

    // MARK: - Public Methods

    /// Start a new challenge with the selected category
    func startChallenge(category: ChallengeCategory) {
        selectedCategory = category
        flowState = .beforePhoto
        reset()

        // Audio & Haptic feedback
        audioManager.playFeedback(sound: .buttonPress, haptic: .medium)
    }

    /// Capture the "before" photo
    func captureBeforePhoto(_ image: UIImage) {
        beforeImage = image
        flowState = .afterPhoto

        // Audio & Haptic feedback
        audioManager.playFeedback(sound: .photoCapture, haptic: .medium)
    }

    /// Capture the "after" photo
    func captureAfterPhoto(_ image: UIImage) {
        afterImage = image

        // Audio & Haptic feedback
        audioManager.playFeedback(sound: .photoCapture, haptic: .medium)

        Task {
            await processChallenge()
        }
    }

    /// Process the challenge (calculate score and save)
    func processChallenge() async {
        guard let category = selectedCategory,
              let before = beforeImage,
              let after = afterImage else {
            errorMessage = "Fehlende Bilder oder Kategorie"
            return
        }

        isProcessing = true
        flowState = .processing

        // Play scoring sound
        audioManager.playSound(.scoreCalculating)

        do {
            // Save photos
            let beforePath = try await repository.savePhoto(before)
            let afterPath = try await repository.savePhoto(after)

            // Calculate score
            let score = await scoringEngine.calculateScore(
                beforeImage: before,
                afterImage: after,
                category: category
            )

            // Create challenge
            let challenge = Challenge(
                category: category,
                beforePhotoPath: beforePath,
                afterPhotoPath: afterPath,
                score: score
            )

            // Save to repository
            try await repository.saveChallengeHistory(challenge)

            // Update quests
            await updateQuestsForChallenge(category: category)

            // Update goal
            await updateGoalForChallenge(points: score.overallScore)

            // Update UI
            currentScore = score
            flowState = .result

            // Audio & Haptic feedback based on score
            audioManager.playSound(.scoreReveal)
            audioManager.triggerHaptic(.scoreReveal(score: score.overallScore))

            // Additional feedback for high scores
            if score.overallScore >= 85 {
                // Small delay for effect
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                audioManager.playFeedback(sound: .success, haptic: .success)
            }

        } catch {
            errorMessage = "Fehler beim Verarbeiten: \(error.localizedDescription)"
            flowState = .result

            // Error feedback
            audioManager.playFeedback(sound: .error, haptic: .error)
        }

        isProcessing = false
    }

    /// Retry the challenge (take new photos)
    func retryChallenge() {
        flowState = .beforePhoto
        beforeImage = nil
        afterImage = nil
        currentScore = nil
        errorMessage = nil

        // Audio feedback
        audioManager.playFeedback(sound: .buttonTap, haptic: .light)
    }

    /// Complete the challenge and return to start
    func completeChallenge() {
        reset()
        flowState = .categorySelection
        selectedCategory = nil

        // Audio feedback
        audioManager.playFeedback(sound: .buttonTap, haptic: .light)
    }

    /// Reset the challenge state
    func reset() {
        beforeImage = nil
        afterImage = nil
        currentScore = nil
        errorMessage = nil
        isProcessing = false
    }

    // MARK: - Private Methods

    /// Update quests for completed challenge
    private func updateQuestsForChallenge(category: ChallengeCategory) async {
        do {
            let quests = try await repository.getActiveQuests()

            for quest in quests where quest.category == category {
                let newProgress = quest.currentProgress + 1
                try await repository.updateQuestProgress(
                    questId: quest.id,
                    newProgress: newProgress
                )
            }
        } catch {
            print("Error updating quests: \(error)")
        }
    }

    /// Update goal for completed challenge
    private func updateGoalForChallenge(points: Int) async {
        do {
            try await repository.updateGoalProgress(points: points)
        } catch {
            print("Error updating goal: \(error)")
        }
    }
}
