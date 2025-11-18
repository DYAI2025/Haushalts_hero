//
//  AppRepository.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import UIKit

/// Protocol defining the data access layer for the app
/// This abstraction allows for different implementations (local, remote, mock)
protocol AppRepository {

    // MARK: - Challenge Operations

    /// Save a completed challenge to history
    /// - Parameter challenge: The challenge to save
    /// - Throws: Repository errors if save fails
    func saveChallengeHistory(_ challenge: Challenge) async throws

    /// Get challenge history
    /// - Parameter limit: Optional limit on number of results (nil = all)
    /// - Returns: Array of challenges, sorted by timestamp (newest first)
    /// - Throws: Repository errors if fetch fails
    func getChallengeHistory(limit: Int?) async throws -> [Challenge]

    /// Get challenges for a specific week
    /// - Parameter startDate: Start date of the week
    /// - Returns: Array of challenges for that week
    /// - Throws: Repository errors if fetch fails
    func getChallengesForWeek(startDate: Date) async throws -> [Challenge]

    /// Delete a challenge by ID
    /// - Parameter id: The challenge ID to delete
    /// - Throws: Repository errors if delete fails
    func deleteChallenge(id: UUID) async throws

    // MARK: - Quests & Goals

    /// Get all active quests for the current week
    /// - Returns: Array of active quests
    /// - Throws: Repository errors if fetch fails
    func getActiveQuests() async throws -> [Quest]

    /// Update quest progress
    /// - Parameters:
    ///   - questId: ID of the quest to update
    ///   - newProgress: New progress value
    /// - Throws: Repository errors if update fails
    func updateQuestProgress(questId: UUID, newProgress: Int) async throws

    /// Get the active goal for the current week
    /// - Returns: The active goal, or nil if none exists
    /// - Throws: Repository errors if fetch fails
    func getActiveGoal() async throws -> Goal?

    /// Update goal progress
    /// - Parameter points: Points to add to the current goal
    /// - Throws: Repository errors if update fails
    func updateGoalProgress(points: Int) async throws

    /// Reset weekly quests and goals (called at week start)
    /// - Throws: Repository errors if reset fails
    func resetWeeklyProgress() async throws

    // MARK: - Statistics

    /// Get weekly statistics for a specific week
    /// - Parameter weekStart: Start date of the week
    /// - Returns: WeeklyStats for that week
    /// - Throws: Repository errors if fetch fails
    func getWeeklyStats(weekStart: Date) async throws -> WeeklyStats

    /// Update weekly statistics
    /// - Parameter stats: Updated statistics
    /// - Throws: Repository errors if update fails
    func updateWeeklyStats(_ stats: WeeklyStats) async throws

    /// Get monthly statistics
    /// - Parameter monthStart: Start date of the month
    /// - Returns: Array of WeeklyStats for that month
    /// - Throws: Repository errors if fetch fails
    func getMonthlyStats(monthStart: Date) async throws -> [WeeklyStats]

    // MARK: - Content (Coaching & Learning)

    /// Get relevant coaching tips for a score
    /// - Parameter score: The score to get tips for
    /// - Returns: Array of matching coaching tips, sorted by priority
    /// - Throws: Repository errors if fetch fails
    func getCoachingTips(for score: ExplainableScore) async throws -> [CoachTip]

    /// Get all coaching tips (for browsing)
    /// - Returns: All available coaching tips
    /// - Throws: Repository errors if fetch fails
    func getAllCoachingTips() async throws -> [CoachTip]

    /// Get micro-learning cards
    /// - Parameter category: Optional category filter
    /// - Returns: Array of micro-learning cards
    /// - Throws: Repository errors if fetch fails
    func getMicroLearningCards(category: ChallengeCategory?) async throws -> [MicroLearningCard]

    /// Get the currently active season
    /// - Returns: Active season, or nil if none is active
    /// - Throws: Repository errors if fetch fails
    func getActiveSeason() async throws -> Season?

    /// Get all seasons (for preview/history)
    /// - Returns: All available seasons
    /// - Throws: Repository errors if fetch fails
    func getAllSeasons() async throws -> [Season]

    // MARK: - Settings

    /// Save user settings
    /// - Parameter settings: Settings to save
    /// - Throws: Repository errors if save fails
    func saveUserSettings(_ settings: UserSettings) async throws

    /// Get user settings
    /// - Returns: Current user settings
    /// - Throws: Repository errors if fetch fails
    func getUserSettings() async throws -> UserSettings

    // MARK: - Photo Management

    /// Save a photo to local storage
    /// - Parameter image: The image to save
    /// - Returns: File path where the image was saved
    /// - Throws: Repository errors if save fails
    func savePhoto(_ image: UIImage) async throws -> String

    /// Load a photo from local storage
    /// - Parameter path: File path of the image
    /// - Returns: The loaded image, or nil if not found
    /// - Throws: Repository errors if load fails
    func loadPhoto(path: String) async throws -> UIImage?

    /// Delete a photo from local storage
    /// - Parameter path: File path of the image
    /// - Throws: Repository errors if delete fails
    func deletePhoto(path: String) async throws
}

/// Repository-specific errors
enum RepositoryError: Error, LocalizedError {
    case notFound(String)
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case invalidData(String)
    case storageError(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let msg): return "Nicht gefunden: \(msg)"
        case .saveFailed(let msg): return "Speichern fehlgeschlagen: \(msg)"
        case .loadFailed(let msg): return "Laden fehlgeschlagen: \(msg)"
        case .deleteFailed(let msg): return "Löschen fehlgeschlagen: \(msg)"
        case .invalidData(let msg): return "Ungültige Daten: \(msg)"
        case .storageError(let msg): return "Speicherfehler: \(msg)"
        }
    }
}
