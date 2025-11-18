//
//  Quest.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// Represents a weekly quest/mission for the user
struct Quest: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let targetCount: Int
    var currentProgress: Int
    let category: ChallengeCategory?
    let weekStart: Date
    let rewardPoints: Int

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetCount: Int,
        currentProgress: Int = 0,
        category: ChallengeCategory? = nil,
        weekStart: Date,
        rewardPoints: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetCount = targetCount
        self.currentProgress = currentProgress
        self.category = category
        self.weekStart = weekStart
        self.rewardPoints = rewardPoints
    }

    /// Progress percentage (0-100)
    var progressPercentage: Int {
        guard targetCount > 0 else { return 0 }
        return min(100, (currentProgress * 100) / targetCount)
    }

    /// Whether the quest is completed
    var isCompleted: Bool {
        return currentProgress >= targetCount
    }

    /// Whether the quest is still active (within current week)
    func isActive(currentDate: Date = Date()) -> Bool {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        return currentDate >= weekStart && currentDate < weekEnd
    }
}

/// Represents a household goal
struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let targetPoints: Int
    var currentPoints: Int
    let weekStart: Date
    let icon: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetPoints: Int,
        currentPoints: Int = 0,
        weekStart: Date,
        icon: String = "target"
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetPoints = targetPoints
        self.currentPoints = currentPoints
        self.weekStart = weekStart
        self.icon = icon
    }

    /// Progress percentage (0-100)
    var progressPercentage: Int {
        guard targetPoints > 0 else { return 0 }
        return min(100, (currentPoints * 100) / targetPoints)
    }

    /// Whether the goal is completed
    var isCompleted: Bool {
        return currentPoints >= targetPoints
    }

    /// Whether the goal is still active (within current week)
    func isActive(currentDate: Date = Date()) -> Bool {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        return currentDate >= weekStart && currentDate < weekEnd
    }
}
