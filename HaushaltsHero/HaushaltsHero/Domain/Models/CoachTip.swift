//
//  CoachTip.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// Represents a coaching tip shown after a challenge
struct CoachTip: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let triggerRules: [TriggerRule]
    let category: ChallengeCategory?
    let priority: Int  // Higher priority = shown first

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        triggerRules: [TriggerRule] = [],
        category: ChallengeCategory? = nil,
        priority: Int = 0
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.triggerRules = triggerRules
        self.category = category
        self.priority = priority
    }

    /// Check if this tip should be shown for the given score
    func shouldShow(for score: ExplainableScore) -> Bool {
        guard !triggerRules.isEmpty else { return true }

        // All rules must match
        return triggerRules.allSatisfy { rule in
            rule.matches(score: score)
        }
    }
}

/// Trigger rule for when to show a coaching tip
struct TriggerRule: Codable, Equatable {
    let subscoreName: String?
    let minValue: Int?
    let maxValue: Int?
    let confidenceThreshold: Double?

    init(
        subscoreName: String? = nil,
        minValue: Int? = nil,
        maxValue: Int? = nil,
        confidenceThreshold: Double? = nil
    ) {
        self.subscoreName = subscoreName
        self.minValue = minValue
        self.maxValue = maxValue
        self.confidenceThreshold = confidenceThreshold
    }

    /// Check if this rule matches the given score
    func matches(score: ExplainableScore) -> Bool {
        // Check confidence threshold
        if let threshold = confidenceThreshold {
            if score.confidence < threshold {
                return false
            }
        }

        // Check subscore range
        if let name = subscoreName {
            guard let subscore = score.subscores.first(where: { $0.name == name }) else {
                return false
            }

            if let min = minValue, subscore.value < min {
                return false
            }

            if let max = maxValue, subscore.value > max {
                return false
            }
        }

        return true
    }
}

/// Micro-learning card for educational content
struct MicroLearningCard: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let imageURL: String?
    let category: ChallengeCategory
    let tags: [String]
    let estimatedReadTime: Int  // in seconds

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        imageURL: String? = nil,
        category: ChallengeCategory,
        tags: [String] = [],
        estimatedReadTime: Int = 60
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.imageURL = imageURL
        self.category = category
        self.tags = tags
        self.estimatedReadTime = estimatedReadTime
    }
}

/// Season/Event definition
struct Season: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let theme: String
    let bannerImageURL: String?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        theme: String,
        bannerImageURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.theme = theme
        self.bannerImageURL = bannerImageURL
    }

    /// Check if the season is currently active
    func isActive(currentDate: Date = Date()) -> Bool {
        return currentDate >= startDate && currentDate <= endDate
    }
}
