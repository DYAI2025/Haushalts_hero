//
//  CoachingEngine.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// Engine for matching coaching tips to challenge scores
class CoachingEngine {

    // MARK: - Public Methods

    /// Get relevant coaching tips for a given score
    /// - Parameters:
    ///   - score: The explainable score to analyze
    ///   - allTips: All available coaching tips
    ///   - maxTips: Maximum number of tips to return (default: 3)
    /// - Returns: Array of matched coaching tips, sorted by priority
    func getRelevantTips(
        for score: ExplainableScore,
        from allTips: [CoachTip],
        maxTips: Int = 3
    ) -> [CoachTip] {
        // Filter tips that match the score
        let matchedTips = allTips.filter { tip in
            shouldShow(tip: tip, for: score)
        }

        // Sort by priority (highest first)
        let sortedTips = matchedTips.sorted { $0.priority > $1.priority }

        // Return top N tips
        return Array(sortedTips.prefix(maxTips))
    }

    /// Get improvement suggestions based on weakest subscores
    /// - Parameter score: The score to analyze
    /// - Returns: Array of improvement areas
    func getImprovementAreas(for score: ExplainableScore) -> [ImprovementArea] {
        // Sort subscores by value (lowest first)
        let sortedSubscores = score.subscores.sorted { $0.value < $1.value }

        // Identify weak areas (score < 70)
        return sortedSubscores
            .filter { $0.value < 70 }
            .prefix(3)
            .map { subscore in
                ImprovementArea(
                    name: subscore.name,
                    currentValue: subscore.value,
                    targetValue: 80,
                    priority: calculateImprovementPriority(subscore: subscore)
                )
            }
    }

    /// Calculate a motivational streak bonus
    /// - Parameter recentScores: Array of recent challenge scores
    /// - Returns: Streak information
    func calculateStreak(from recentScores: [Int]) -> StreakInfo {
        guard !recentScores.isEmpty else {
            return StreakInfo(count: 0, isActive: false, message: "Starte deine erste Challenge!")
        }

        var currentStreak = 0
        let threshold = 70 // Minimum score to count as "good"

        // Count consecutive good scores
        for score in recentScores.reversed() {
            if score >= threshold {
                currentStreak += 1
            } else {
                break
            }
        }

        let message: String
        if currentStreak == 0 {
            message = "Beim nächsten Mal wird es besser! 💪"
        } else if currentStreak < 3 {
            message = "Du bist auf einem guten Weg! 🚀"
        } else if currentStreak < 5 {
            message = "Fantastische Serie! Weiter so! ⭐"
        } else {
            message = "Unglaubliche \(currentStreak)er-Serie! Du bist ein Profi! 🌟"
        }

        return StreakInfo(
            count: currentStreak,
            isActive: currentStreak > 0,
            message: message
        )
    }

    // MARK: - Private Methods

    /// Check if a tip should be shown for the given score
    private func shouldShow(tip: CoachTip, for score: ExplainableScore) -> Bool {
        // If no trigger rules, always show (general tip)
        guard !tip.triggerRules.isEmpty else { return true }

        // All rules must match (AND logic)
        return tip.triggerRules.allSatisfy { rule in
            matches(rule: rule, score: score)
        }
    }

    /// Check if a trigger rule matches the score
    private func matches(rule: TriggerRule, score: ExplainableScore) -> Bool {
        // Check confidence threshold
        if let threshold = rule.confidenceThreshold {
            if score.confidence < threshold {
                return false
            }
        }

        // Check overall score range
        if rule.subscoreName == nil {
            // Rule applies to overall score
            if let min = rule.minValue, score.overallScore < min {
                return false
            }
            if let max = rule.maxValue, score.overallScore > max {
                return false
            }
            return true
        }

        // Check specific subscore
        if let subscoreName = rule.subscoreName {
            guard let subscore = score.subscores.first(where: { $0.name == subscoreName }) else {
                return false
            }

            if let min = rule.minValue, subscore.value < min {
                return false
            }
            if let max = rule.maxValue, subscore.value > max {
                return false
            }
        }

        return true
    }

    /// Calculate improvement priority for a subscore
    private func calculateImprovementPriority(subscore: Subscore) -> ImprovementPriority {
        let value = subscore.value

        if value < 40 {
            return .critical
        } else if value < 60 {
            return .high
        } else if value < 70 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - Supporting Types

/// Represents an area for improvement
struct ImprovementArea {
    let name: String
    let currentValue: Int
    let targetValue: Int
    let priority: ImprovementPriority

    var improvementNeeded: Int {
        return max(0, targetValue - currentValue)
    }
}

enum ImprovementPriority: String {
    case critical = "Dringend"
    case high = "Wichtig"
    case medium = "Normal"
    case low = "Optional"

    var color: String {
        switch self {
        case .critical: return "red"
        case .high: return "orange"
        case .medium: return "yellow"
        case .low: return "green"
        }
    }
}

/// Streak information
struct StreakInfo {
    let count: Int
    let isActive: Bool
    let message: String
}
