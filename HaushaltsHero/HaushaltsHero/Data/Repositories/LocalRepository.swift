//
//  LocalRepository.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import UIKit

/// Local implementation of AppRepository using UserDefaults and FileManager
class LocalRepository: AppRepository {

    // MARK: - Storage Keys

    private enum StorageKey: String {
        case challenges = "haushalts_hero.challenges"
        case quests = "haushalts_hero.quests"
        case goal = "haushalts_hero.goal"
        case weeklyStats = "haushalts_hero.weekly_stats"
        case userSettings = "haushalts_hero.user_settings"
        case coachingTips = "haushalts_hero.coaching_tips"
        case microLearningCards = "haushalts_hero.micro_learning_cards"
        case seasons = "haushalts_hero.seasons"
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let photosDirectory: URL

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager

        // Setup photos directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.photosDirectory = documentsPath.appendingPathComponent("Photos", isDirectory: true)

        // Create photos directory if it doesn't exist
        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)

        // Initialize with dummy data if first launch
        initializeDummyDataIfNeeded()
    }

    // MARK: - Challenge Operations

    func saveChallengeHistory(_ challenge: Challenge) async throws {
        var challenges = try await getChallengeHistory(limit: nil)
        challenges.insert(challenge, at: 0)

        let data = try JSONEncoder().encode(challenges)
        userDefaults.set(data, forKey: StorageKey.challenges.rawValue)

        // Update weekly stats
        await updateStatsForNewChallenge(challenge)
    }

    func getChallengeHistory(limit: Int?) async throws -> [Challenge] {
        guard let data = userDefaults.data(forKey: StorageKey.challenges.rawValue) else {
            return []
        }

        let challenges = try JSONDecoder().decode([Challenge].self, from: data)
        if let limit = limit {
            return Array(challenges.prefix(limit))
        }
        return challenges
    }

    func getChallengesForWeek(startDate: Date) async throws -> [Challenge] {
        let challenges = try await getChallengeHistory(limit: nil)
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate

        return challenges.filter { challenge in
            challenge.timestamp >= startDate && challenge.timestamp < weekEnd
        }
    }

    func deleteChallenge(id: UUID) async throws {
        var challenges = try await getChallengeHistory(limit: nil)
        challenges.removeAll { $0.id == id }

        let data = try JSONEncoder().encode(challenges)
        userDefaults.set(data, forKey: StorageKey.challenges.rawValue)
    }

    // MARK: - Quests & Goals

    func getActiveQuests() async throws -> [Quest] {
        guard let data = userDefaults.data(forKey: StorageKey.quests.rawValue) else {
            return getDefaultQuests()
        }

        let quests = try JSONDecoder().decode([Quest].self, from: data)
        return quests.filter { $0.isActive() }
    }

    func updateQuestProgress(questId: UUID, newProgress: Int) async throws {
        var quests = try await getActiveQuests()
        if let index = quests.firstIndex(where: { $0.id == questId }) {
            quests[index].currentProgress = newProgress
        }

        let data = try JSONEncoder().encode(quests)
        userDefaults.set(data, forKey: StorageKey.quests.rawValue)
    }

    func getActiveGoal() async throws -> Goal? {
        guard let data = userDefaults.data(forKey: StorageKey.goal.rawValue) else {
            return getDefaultGoal()
        }

        let goal = try JSONDecoder().decode(Goal.self, from: data)
        return goal.isActive() ? goal : nil
    }

    func updateGoalProgress(points: Int) async throws {
        guard var goal = try await getActiveGoal() else { return }

        goal.currentPoints += points

        let data = try JSONEncoder().encode(goal)
        userDefaults.set(data, forKey: StorageKey.goal.rawValue)
    }

    func resetWeeklyProgress() async throws {
        // Reset quests
        let newQuests = getDefaultQuests()
        let data = try JSONEncoder().encode(newQuests)
        userDefaults.set(data, forKey: StorageKey.quests.rawValue)

        // Reset goal
        let newGoal = getDefaultGoal()
        let goalData = try JSONEncoder().encode(newGoal)
        userDefaults.set(goalData, forKey: StorageKey.goal.rawValue)
    }

    // MARK: - Statistics

    func getWeeklyStats(weekStart: Date) async throws -> WeeklyStats {
        guard let data = userDefaults.data(forKey: StorageKey.weeklyStats.rawValue) else {
            return WeeklyStats(weekStart: weekStart)
        }

        let allStats = try JSONDecoder().decode([WeeklyStats].self, from: data)
        return allStats.first { Calendar.current.isDate($0.weekStart, equalTo: weekStart, toGranularity: .day) }
            ?? WeeklyStats(weekStart: weekStart)
    }

    func updateWeeklyStats(_ stats: WeeklyStats) async throws {
        var allStats: [WeeklyStats] = []

        if let data = userDefaults.data(forKey: StorageKey.weeklyStats.rawValue) {
            allStats = try JSONDecoder().decode([WeeklyStats].self, from: data)
        }

        if let index = allStats.firstIndex(where: {
            Calendar.current.isDate($0.weekStart, equalTo: stats.weekStart, toGranularity: .day)
        }) {
            allStats[index] = stats
        } else {
            allStats.append(stats)
        }

        let data = try JSONEncoder().encode(allStats)
        userDefaults.set(data, forKey: StorageKey.weeklyStats.rawValue)
    }

    func getMonthlyStats(monthStart: Date) async throws -> [WeeklyStats] {
        guard let data = userDefaults.data(forKey: StorageKey.weeklyStats.rawValue) else {
            return []
        }

        let allStats = try JSONDecoder().decode([WeeklyStats].self, from: data)
        let calendar = Calendar.current
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart

        return allStats.filter { stat in
            stat.weekStart >= monthStart && stat.weekStart < monthEnd
        }
    }

    // MARK: - Content

    func getCoachingTips(for score: ExplainableScore) async throws -> [CoachTip] {
        let allTips = try await getAllCoachingTips()
        return allTips
            .filter { $0.shouldShow(for: score) }
            .sorted { $0.priority > $1.priority }
    }

    func getAllCoachingTips() async throws -> [CoachTip] {
        guard let data = userDefaults.data(forKey: StorageKey.coachingTips.rawValue) else {
            return getDefaultCoachingTips()
        }

        return try JSONDecoder().decode([CoachTip].self, from: data)
    }

    func getMicroLearningCards(category: ChallengeCategory?) async throws -> [MicroLearningCard] {
        guard let data = userDefaults.data(forKey: StorageKey.microLearningCards.rawValue) else {
            return getDefaultMicroLearningCards()
        }

        let cards = try JSONDecoder().decode([MicroLearningCard].self, from: data)
        if let category = category {
            return cards.filter { $0.category == category }
        }
        return cards
    }

    func getActiveSeason() async throws -> Season? {
        let seasons = try await getAllSeasons()
        return seasons.first { $0.isActive() }
    }

    func getAllSeasons() async throws -> [Season] {
        guard let data = userDefaults.data(forKey: StorageKey.seasons.rawValue) else {
            return getDefaultSeasons()
        }

        return try JSONDecoder().decode([Season].self, from: data)
    }

    // MARK: - Settings

    func saveUserSettings(_ settings: UserSettings) async throws {
        let data = try JSONEncoder().encode(settings)
        userDefaults.set(data, forKey: StorageKey.userSettings.rawValue)
    }

    func getUserSettings() async throws -> UserSettings {
        guard let data = userDefaults.data(forKey: StorageKey.userSettings.rawValue) else {
            return .default
        }

        return try JSONDecoder().decode(UserSettings.self, from: data)
    }

    // MARK: - Photo Management

    func savePhoto(_ image: UIImage) async throws -> String {
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw RepositoryError.saveFailed("Could not convert image to JPEG")
        }

        try data.write(to: fileURL)
        return fileURL.path
    }

    func loadPhoto(path: String) async throws -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }

    func deletePhoto(path: String) async throws {
        let fileURL = URL(fileURLWithPath: path)
        try fileManager.removeItem(at: fileURL)
    }

    // MARK: - Helper Methods

    private func updateStatsForNewChallenge(_ challenge: Challenge) async {
        guard let score = challenge.score else { return }

        let weekStart = Date.startOfCurrentWeek()
        var stats = (try? await getWeeklyStats(weekStart: weekStart)) ?? WeeklyStats(weekStart: weekStart)

        stats.addChallenge(category: challenge.category, score: score.overallScore)

        try? await updateWeeklyStats(stats)
    }

    // MARK: - Dummy Data Initialization

    private func initializeDummyDataIfNeeded() {
        let isFirstLaunch = !userDefaults.bool(forKey: "haushalts_hero.has_launched")

        if isFirstLaunch {
            // Initialize with default data
            let quests = getDefaultQuests()
            let goal = getDefaultGoal()
            let coachingTips = getDefaultCoachingTips()
            let microLearningCards = getDefaultMicroLearningCards()
            let seasons = getDefaultSeasons()
            let settings = UserSettings.default

            if let questsData = try? JSONEncoder().encode(quests) {
                userDefaults.set(questsData, forKey: StorageKey.quests.rawValue)
            }

            if let goalData = try? JSONEncoder().encode(goal) {
                userDefaults.set(goalData, forKey: StorageKey.goal.rawValue)
            }

            if let tipsData = try? JSONEncoder().encode(coachingTips) {
                userDefaults.set(tipsData, forKey: StorageKey.coachingTips.rawValue)
            }

            if let cardsData = try? JSONEncoder().encode(microLearningCards) {
                userDefaults.set(cardsData, forKey: StorageKey.microLearningCards.rawValue)
            }

            if let seasonsData = try? JSONEncoder().encode(seasons) {
                userDefaults.set(seasonsData, forKey: StorageKey.seasons.rawValue)
            }

            if let settingsData = try? JSONEncoder().encode(settings) {
                userDefaults.set(settingsData, forKey: StorageKey.userSettings.rawValue)
            }

            userDefaults.set(true, forKey: "haushalts_hero.has_launched")
        }
    }

    // MARK: - Default Data Generators

    private func getDefaultQuests() -> [Quest] {
        let weekStart = Date.startOfCurrentWeek()

        return [
            Quest(
                title: "Spiegel-Profi",
                description: "Putze 3 Spiegel diese Woche",
                targetCount: 3,
                currentProgress: 0,
                category: .mirror,
                weekStart: weekStart,
                rewardPoints: 150
            ),
            Quest(
                title: "Toiletten-Meister",
                description: "Reinige 2 Toiletten diese Woche",
                targetCount: 2,
                currentProgress: 0,
                category: .toilet,
                weekStart: weekStart,
                rewardPoints: 100
            ),
            Quest(
                title: "Ordnungs-Champion",
                description: "Räume 5 Zimmer auf diese Woche",
                targetCount: 5,
                currentProgress: 0,
                category: .room,
                weekStart: weekStart,
                rewardPoints: 200
            )
        ]
    }

    private func getDefaultGoal() -> Goal {
        let weekStart = Date.startOfCurrentWeek()

        return Goal(
            title: "Haushalts-Held",
            description: "Erreiche 500 Punkte diese Woche",
            targetPoints: 500,
            currentPoints: 0,
            weekStart: weekStart,
            icon: "star.fill"
        )
    }

    private func getDefaultCoachingTips() -> [CoachTip] {
        // Load from JSON file
        return loadCoachingTipsFromJSON() ?? []
    }

    private func loadCoachingTipsFromJSON() -> [CoachTip]? {
        guard let url = Bundle.main.url(forResource: "coaching_tips", withExtension: "json", subdirectory: "Resources/Content") else {
            print("Warning: coaching_tips.json not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()

            // Custom JSON structure that matches our file format
            struct JSONCoachTip: Codable {
                let id: String
                let title: String
                let content: String
                let triggerRules: [JSONTriggerRule]
                let category: String?
                let priority: Int
            }

            struct JSONTriggerRule: Codable {
                let subscoreName: String?
                let minValue: Int?
                let maxValue: Int?
                let confidenceThreshold: Double?
            }

            let jsonTips = try decoder.decode([JSONCoachTip].self, from: data)

            return jsonTips.map { jsonTip in
                let category: ChallengeCategory? = {
                    guard let catString = jsonTip.category else { return nil }
                    return ChallengeCategory(rawValue: catString)
                }()

                let rules = jsonTip.triggerRules.map { jsonRule in
                    TriggerRule(
                        subscoreName: jsonRule.subscoreName,
                        minValue: jsonRule.minValue,
                        maxValue: jsonRule.maxValue,
                        confidenceThreshold: jsonRule.confidenceThreshold
                    )
                }

                return CoachTip(
                    id: UUID(),
                    title: jsonTip.title,
                    content: jsonTip.content,
                    triggerRules: rules,
                    category: category,
                    priority: jsonTip.priority
                )
            }
        } catch {
            print("Error loading coaching tips from JSON: \(error)")
            return nil
        }
    }

    private func getDefaultMicroLearningCards() -> [MicroLearningCard] {
        // Load from JSON file
        return loadMicroLearningCardsFromJSON() ?? []
    }

    private func loadMicroLearningCardsFromJSON() -> [MicroLearningCard]? {
        guard let url = Bundle.main.url(forResource: "microlearning", withExtension: "json", subdirectory: "Resources/Content") else {
            print("Warning: microlearning.json not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()

            // Custom JSON structure
            struct JSONMicroLearningCard: Codable {
                let id: String
                let title: String
                let content: String
                let imageURL: String?
                let category: String
                let tags: [String]
                let estimatedReadTime: Int
            }

            let jsonCards = try decoder.decode([JSONMicroLearningCard].self, from: data)

            return jsonCards.compactMap { jsonCard in
                guard let category = ChallengeCategory(rawValue: jsonCard.category) else {
                    return nil
                }

                return MicroLearningCard(
                    id: UUID(),
                    title: jsonCard.title,
                    content: jsonCard.content,
                    imageURL: jsonCard.imageURL,
                    category: category,
                    tags: jsonCard.tags,
                    estimatedReadTime: jsonCard.estimatedReadTime
                )
            }
        } catch {
            print("Error loading micro learning cards from JSON: \(error)")
            return nil
        }
    }

    private func getDefaultSeasons() -> [Season] {
        let calendar = Calendar.current
        let now = Date()

        // Create a winter cleaning season
        let winterStart = calendar.date(from: DateComponents(year: 2025, month: 11, day: 1)) ?? now
        let winterEnd = calendar.date(from: DateComponents(year: 2026, month: 1, day: 31)) ?? now

        return [
            Season(
                title: "Winter-Putz 2025",
                description: "Mach dein Zuhause bereit für die kalte Jahreszeit!",
                startDate: winterStart,
                endDate: winterEnd,
                theme: "winter",
                bannerImageURL: nil
            )
        ]
    }
}
