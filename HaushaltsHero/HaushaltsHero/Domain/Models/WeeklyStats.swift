//
//  WeeklyStats.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// Represents weekly statistics for user progress
struct WeeklyStats: Codable, Equatable {
    let weekStart: Date
    var challengesCompleted: Int
    var averageScore: Double
    var categoryCounts: [String: Int]  // ChallengeCategory.rawValue -> count
    var totalPoints: Int

    init(
        weekStart: Date,
        challengesCompleted: Int = 0,
        averageScore: Double = 0.0,
        categoryCounts: [String: Int] = [:],
        totalPoints: Int = 0
    ) {
        self.weekStart = weekStart
        self.challengesCompleted = challengesCompleted
        self.averageScore = averageScore
        self.categoryCounts = categoryCounts
        self.totalPoints = totalPoints
    }

    /// Get the most frequently completed category
    var topCategory: ChallengeCategory? {
        guard let topEntry = categoryCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return ChallengeCategory(rawValue: topEntry.key)
    }

    /// Update stats with a new challenge
    mutating func addChallenge(category: ChallengeCategory, score: Int) {
        challengesCompleted += 1

        // Update average score
        let totalScore = averageScore * Double(challengesCompleted - 1) + Double(score)
        averageScore = totalScore / Double(challengesCompleted)

        // Update category counts
        let categoryKey = category.rawValue
        categoryCounts[categoryKey, default: 0] += 1

        // Add points (simplified: score = points for MVP)
        totalPoints += score
    }

    /// Check if this stats object is for the current week
    func isCurrentWeek(date: Date = Date()) -> Bool {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
        return date >= weekStart && date < weekEnd
    }
}

/// Helper to get week start date
extension Date {
    /// Get the start of the current week (Monday at 00:00)
    static func startOfCurrentWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)

        // Calculate days to subtract to get to Monday (weekday 2 in Gregorian calendar)
        let daysToSubtract = (weekday == 1) ? 6 : weekday - 2

        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: now) else {
            return now
        }

        return calendar.startOfDay(for: monday)
    }
}
