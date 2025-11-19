//
//  MockRepository.swift
//  HaushaltsHeroTests
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import UIKit
@testable import HaushaltsHero

/// Mock repository for testing ViewModels
class MockRepository: AppRepository {

    // MARK: - Challenge History

    var savedChallenges: [Challenge] = []
    var challengeHistoryToReturn: [Challenge] = []
    var shouldThrowError = false

    func saveChallengeHistory(_ challenge: Challenge) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        savedChallenges.append(challenge)
    }

    func getChallengeHistory(limit: Int?) async throws -> [Challenge] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        if let limit = limit {
            return Array(challengeHistoryToReturn.prefix(limit))
        }
        return challengeHistoryToReturn
    }

    func getChallengesForWeek(startDate: Date) async throws -> [Challenge] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return challengeHistoryToReturn.filter { challenge in
            let weekInterval: TimeInterval = 7 * 24 * 60 * 60
            return challenge.timestamp >= startDate && challenge.timestamp < startDate.addingTimeInterval(weekInterval)
        }
    }

    func deleteChallenge(id: UUID) async throws {
        if shouldThrowError {
            throw RepositoryError.deleteFailed("Mock error")
        }
        savedChallenges.removeAll { $0.id == id }
    }

    // MARK: - Quests & Goals

    var activeQuestsToReturn: [Quest] = []
    var activeGoalToReturn: Goal?
    var questProgressUpdates: [(UUID, Int)] = []
    var goalProgressUpdates: [Int] = []

    func getActiveQuests() async throws -> [Quest] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return activeQuestsToReturn
    }

    func updateQuestProgress(questId: UUID, newProgress: Int) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        questProgressUpdates.append((questId, newProgress))

        // Update the quest in activeQuestsToReturn
        if let index = activeQuestsToReturn.firstIndex(where: { $0.id == questId }) {
            var updatedQuest = activeQuestsToReturn[index]
            updatedQuest.currentProgress = newProgress
            activeQuestsToReturn[index] = updatedQuest
        }
    }

    func getActiveGoal() async throws -> Goal? {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return activeGoalToReturn
    }

    func updateGoalProgress(points: Int) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        goalProgressUpdates.append(points)

        // Update the goal
        if var goal = activeGoalToReturn {
            goal.currentPoints += points
            activeGoalToReturn = goal
        }
    }

    func resetWeeklyProgress() async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        activeQuestsToReturn = []
        activeGoalToReturn = nil
    }

    // MARK: - Statistics

    var weeklyStatsToReturn: WeeklyStats?
    var monthlyStatsToReturn: [WeeklyStats] = []

    func getWeeklyStats(weekStart: Date) async throws -> WeeklyStats {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return weeklyStatsToReturn ?? WeeklyStats(
            weekStart: weekStart,
            challengesCompleted: 0,
            averageScore: 0.0,
            categoryCounts: [:],
            totalPoints: 0
        )
    }

    func updateWeeklyStats(_ stats: WeeklyStats) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        weeklyStatsToReturn = stats
    }

    func getMonthlyStats(monthStart: Date) async throws -> [WeeklyStats] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return monthlyStatsToReturn
    }

    // MARK: - Content

    var coachingTipsToReturn: [CoachTip] = []
    var allCoachingTipsToReturn: [CoachTip] = []
    var microLearningCardsToReturn: [MicroLearningCard] = []
    var activeSeasonToReturn: Season?
    var allSeasonsToReturn: [Season] = []

    func getCoachingTips(for score: ExplainableScore) async throws -> [CoachTip] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return coachingTipsToReturn
    }

    func getAllCoachingTips() async throws -> [CoachTip] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return allCoachingTipsToReturn
    }

    func getMicroLearningCards(category: ChallengeCategory?) async throws -> [MicroLearningCard] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        if let category = category {
            return microLearningCardsToReturn.filter { $0.category == category }
        }
        return microLearningCardsToReturn
    }

    func getActiveSeason() async throws -> Season? {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return activeSeasonToReturn
    }

    func getAllSeasons() async throws -> [Season] {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return allSeasonsToReturn
    }

    // MARK: - Settings

    var userSettingsToReturn: UserSettings = UserSettings()
    var savedSettings: UserSettings?

    func saveUserSettings(_ settings: UserSettings) async throws {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        savedSettings = settings
        userSettingsToReturn = settings
    }

    func getUserSettings() async throws -> UserSettings {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return userSettingsToReturn
    }

    // MARK: - Photo Management

    var savedPhotos: [String: UIImage] = [:]
    var photoPathCounter = 0

    func savePhoto(_ image: UIImage) async throws -> String {
        if shouldThrowError {
            throw RepositoryError.saveFailed("Mock error")
        }
        photoPathCounter += 1
        let path = "mock_photo_\(photoPathCounter).jpg"
        savedPhotos[path] = image
        return path
    }

    func loadPhoto(path: String) async throws -> UIImage? {
        if shouldThrowError {
            throw RepositoryError.loadFailed("Mock error")
        }
        return savedPhotos[path]
    }

    func deletePhoto(path: String) async throws {
        if shouldThrowError {
            throw RepositoryError.deleteFailed("Mock error")
        }
        savedPhotos.removeValue(forKey: path)
    }
}
