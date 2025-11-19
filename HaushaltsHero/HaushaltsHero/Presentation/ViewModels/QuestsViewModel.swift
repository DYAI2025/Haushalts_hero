//
//  QuestsViewModel.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import Combine

/// ViewModel for Quests and Goals
@MainActor
class QuestsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var activeQuests: [Quest] = []
    @Published var activeGoal: Goal?
    @Published var weeklyStats: WeeklyStats?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository: AppRepository

    // MARK: - Initialization

    init(repository: AppRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Load all quests and goals
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load quests
            activeQuests = try await repository.getActiveQuests()

            // Load goal
            activeGoal = try await repository.getActiveGoal()

            // Load weekly stats
            let weekStart = Date.startOfCurrentWeek()
            weeklyStats = try await repository.getWeeklyStats(weekStart: weekStart)

        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Refresh data
    func refresh() async {
        await loadData()
    }

    /// Get progress text for a quest
    func progressText(for quest: Quest) -> String {
        return "\(quest.currentProgress) / \(quest.targetCount)"
    }

    /// Get remaining count for a quest
    func remainingCount(for quest: Quest) -> Int {
        return max(0, quest.targetCount - quest.currentProgress)
    }

    /// Check if there are any completed quests
    var hasCompletedQuests: Bool {
        activeQuests.contains { $0.isCompleted }
    }

    /// Get completed quests count
    var completedQuestsCount: Int {
        activeQuests.filter { $0.isCompleted }.count
    }

    /// Get total quests count
    var totalQuestsCount: Int {
        activeQuests.count
    }

    /// Calculate total possible reward points
    var totalPossibleRewardPoints: Int {
        activeQuests.reduce(0) { $0 + $1.rewardPoints }
    }

    /// Calculate earned reward points (from completed quests)
    var earnedRewardPoints: Int {
        activeQuests.filter { $0.isCompleted }.reduce(0) { $0 + $1.rewardPoints }
    }
}
