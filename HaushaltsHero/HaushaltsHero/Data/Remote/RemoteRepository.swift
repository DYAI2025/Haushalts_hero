// ============================================
// Remote Repository Implementation
// ============================================

import Foundation
import UIKit

class RemoteRepository: AppRepository {
    // MARK: - Properties

    private let apiClient = APIClient.shared
    private let authManager = AuthenticationManager.shared

    // MARK: - Challenge Methods

    func getChallengeHistory(limit: Int?) async throws -> [Challenge] {
        let limitParam = limit.map { "?limit=\($0)" } ?? ""
        let response: ChallengeListResponse = try await apiClient.get("/challenges\(limitParam)")

        return response.data.map { $0.toDomain() }
    }

    func saveChallengeHistory(_ challenge: Challenge) async throws {
        let request = ChallengeCreateRequest(from: challenge)
        let _: ChallengeDTO = try await apiClient.post("/challenges", body: request)
    }

    func deleteChallengeHistory(_ id: String) async throws {
        try await apiClient.delete("/challenges/\(id)")
    }

    // MARK: - Quest Methods

    func getActiveQuests() async throws -> [Quest] {
        let response: [QuestDTO] = try await apiClient.get("/quests/active")
        return response.map { $0.toDomain() }
    }

    func updateQuestProgress(questId: String, increment: Int) async throws -> Quest {
        let body = QuestProgressUpdate(increment: increment)
        let response: QuestDTO = try await apiClient.patch("/quests/\(questId)/progress", body: body)
        return response.toDomain()
    }

    func resetQuests() async throws -> [Quest] {
        let response: [QuestDTO] = try await apiClient.post("/quests/reset", body: EmptyBody())
        return response.map { $0.toDomain() }
    }

    // MARK: - Goal Methods

    func getActiveGoals() async throws -> [Goal] {
        let response: [GoalDTO] = try await apiClient.get("/goals/active")
        return response.map { $0.toDomain() }
    }

    func updateGoalProgress(points: Int) async throws -> Goal {
        let body = GoalProgressUpdate(points: points)
        let response: GoalDTO = try await apiClient.patch("/goals/progress", body: body)
        return response.toDomain()
    }

    // MARK: - Stats Methods

    func getWeeklyStats() async throws -> WeeklyStats? {
        try await apiClient.get("/stats/weekly")
    }

    func getMonthlyStats(month: String?) async throws -> MonthlyStats {
        let monthParam = month.map { "?month=\($0)" } ?? ""
        return try await apiClient.get("/stats/monthly\(monthParam)")
    }

    func updateWeeklyStats(_ stats: WeeklyStats) async throws {
        let _: WeeklyStats = try await apiClient.put("/stats/weekly", body: stats)
    }

    // MARK: - Content Methods

    func getCoachingTips(context: String?) async throws -> [CoachingTip] {
        let contextParam = context.map { "?context=\($0)" } ?? ""
        return try await apiClient.get("/content/coaching-tips\(contextParam)")
    }

    func getMicroLearningModules() async throws -> [MicroLearning] {
        return try await apiClient.get("/content/micro-learning")
    }

    func getActiveSeason() async throws -> Season? {
        try? await apiClient.get("/content/seasons/active")
    }

    // MARK: - User Settings Methods

    func getUserSettings() async throws -> UserSettings {
        let response: UserWithSettings = try await apiClient.get("/users/me")
        return response.settings ?? UserSettings(
            enableHapticFeedback: true,
            enableSoundEffects: true,
            showHeatmapByDefault: false
        )
    }

    func updateUserSettings(_ settings: UserSettings) async throws {
        let _: UserSettings = try await apiClient.put("/users/me/settings", body: settings)
    }

    // MARK: - Photo Upload

    func uploadPhoto(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.encodingError(NSError(domain: "ImageConversion", code: -1))
        }

        let response = try await apiClient.uploadPhoto(imageData)
        return response.url
    }
}

// MARK: - DTOs (Data Transfer Objects)

struct ChallengeListResponse: Decodable {
    let data: [ChallengeDTO]
    let pagination: Pagination
}

struct Pagination: Decodable {
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool
}

struct ChallengeDTO: Codable {
    let id: String
    let userId: String
    let category: String
    let beforePhotoUrl: String
    let afterPhotoUrl: String
    let timestamp: Date
    let overallScore: Int
    let subscores: [Subscore]
    let confidence: Double
    let explanation: String
    let heatmapData: HeatmapData?
    let createdAt: Date

    func toDomain() -> Challenge {
        Challenge(
            id: id,
            category: ChallengeCategory(rawValue: category) ?? .mirror,
            beforePhotoPath: beforePhotoUrl,
            afterPhotoPath: afterPhotoUrl,
            timestamp: timestamp,
            score: ChallengeScore(
                overallScore: overallScore,
                subscores: subscores,
                confidence: confidence,
                explanation: explanation,
                heatmapData: heatmapData
            )
        )
    }
}

struct ChallengeCreateRequest: Encodable {
    let category: String
    let beforePhotoUrl: String
    let afterPhotoUrl: String
    let score: ScoreRequest

    init(from challenge: Challenge) {
        self.category = challenge.category.rawValue
        self.beforePhotoUrl = challenge.beforePhotoPath
        self.afterPhotoUrl = challenge.afterPhotoPath
        self.score = ScoreRequest(from: challenge.score)
    }

    struct ScoreRequest: Encodable {
        let overallScore: Int
        let subscores: [Subscore]
        let confidence: Double
        let explanation: String
        let heatmapData: HeatmapData?

        init(from score: ChallengeScore) {
            self.overallScore = score.overallScore
            self.subscores = score.subscores
            self.confidence = score.confidence
            self.explanation = score.explanation
            self.heatmapData = score.heatmapData
        }
    }
}

struct QuestDTO: Codable {
    let id: String
    let userId: String
    let title: String
    let description: String
    let category: String?
    let targetCount: Int
    let currentProgress: Int
    let rewardPoints: Int
    let weekStart: Date
    let createdAt: Date
    let updatedAt: Date

    func toDomain() -> Quest {
        Quest(
            id: id,
            title: title,
            description: description,
            category: category,
            targetCount: targetCount,
            currentProgress: currentProgress,
            rewardPoints: rewardPoints,
            weekStart: weekStart
        )
    }
}

struct QuestProgressUpdate: Encodable {
    let increment: Int
}

struct GoalDTO: Codable {
    let id: String
    let userId: String
    let title: String
    let targetPoints: Int
    let currentPoints: Int
    let weekStart: Date
    let createdAt: Date
    let updatedAt: Date

    func toDomain() -> Goal {
        Goal(
            id: id,
            title: title,
            targetPoints: targetPoints,
            currentPoints: currentPoints,
            weekStart: weekStart
        )
    }
}

struct GoalProgressUpdate: Encodable {
    let points: Int
}

struct UserWithSettings: Decodable {
    let id: String
    let email: String
    let createdAt: Date
    let updatedAt: Date
    let settings: UserSettings?
}
