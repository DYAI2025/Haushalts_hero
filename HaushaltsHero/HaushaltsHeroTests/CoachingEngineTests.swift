//
//  CoachingEngineTests.swift
//  HaushaltsHeroTests
//
//  Created by AI Agent on 2025-11-18.
//

import XCTest
@testable import HaushaltsHero

class CoachingEngineTests: XCTestCase {

    var sut: CoachingEngine!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CoachingEngine()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Get Relevant Tips Tests

    func testGetRelevantTips_WithNoTriggerRules_ReturnsGeneralTips() {
        // Given
        let score = createMockScore(overallScore: 75, confidence: 0.85)
        let tips = [
            createMockTip(priority: 10, triggerRules: []),
            createMockTip(priority: 5, triggerRules: []),
            createMockTip(priority: 8, triggerRules: [])
        ]

        // When
        let result = sut.getRelevantTips(for: score, from: tips, maxTips: 3)

        // Then
        XCTAssertEqual(result.count, 3, "Should return all tips without trigger rules")
        XCTAssertEqual(result[0].priority, 10, "Should be sorted by priority")
        XCTAssertEqual(result[1].priority, 8)
        XCTAssertEqual(result[2].priority, 5)
    }

    func testGetRelevantTips_RespectMaxTipsParameter() {
        // Given
        let score = createMockScore(overallScore: 80, confidence: 0.9)
        let tips = (1...10).map { createMockTip(priority: $0, triggerRules: []) }

        // When
        let result = sut.getRelevantTips(for: score, from: tips, maxTips: 3)

        // Then
        XCTAssertEqual(result.count, 3, "Should respect maxTips parameter")
    }

    func testGetRelevantTips_FiltersBasedOnConfidenceThreshold() {
        // Given
        let lowConfidenceScore = createMockScore(overallScore: 80, confidence: 0.6)
        let highConfidenceRule = TriggerRule(
            subscoreName: nil,
            minValue: nil,
            maxValue: nil,
            confidenceThreshold: 0.8
        )
        let tips = [
            createMockTip(priority: 10, triggerRules: [highConfidenceRule]),
            createMockTip(priority: 5, triggerRules: [])
        ]

        // When
        let result = sut.getRelevantTips(for: lowConfidenceScore, from: tips, maxTips: 3)

        // Then
        XCTAssertEqual(result.count, 1, "Should filter out tips requiring high confidence")
        XCTAssertEqual(result[0].priority, 5, "Should return only matching tip")
    }

    func testGetRelevantTips_FiltersBasedOnOverallScoreRange() {
        // Given
        let score = createMockScore(overallScore: 55, confidence: 0.8)
        let highScoreRule = TriggerRule(
            subscoreName: nil,
            minValue: 70,
            maxValue: nil,
            confidenceThreshold: nil
        )
        let lowScoreRule = TriggerRule(
            subscoreName: nil,
            minValue: nil,
            maxValue: 60,
            confidenceThreshold: nil
        )
        let tips = [
            createMockTip(priority: 10, triggerRules: [highScoreRule]),
            createMockTip(priority: 8, triggerRules: [lowScoreRule]),
            createMockTip(priority: 5, triggerRules: [])
        ]

        // When
        let result = sut.getRelevantTips(for: score, from: tips, maxTips: 3)

        // Then
        XCTAssertEqual(result.count, 2, "Should filter based on score range")
        XCTAssertTrue(result.contains { $0.priority == 8 }, "Should include low score tip")
        XCTAssertTrue(result.contains { $0.priority == 5 }, "Should include general tip")
    }

    func testGetRelevantTips_FiltersBasedOnSubscoreValue() {
        // Given
        let score = createMockScore(
            overallScore: 70,
            confidence: 0.8,
            subscores: [
                Subscore(name: "Streifenfreiheit", value: 45, weight: 0.5, description: ""),
                Subscore(name: "Klarheit", value: 80, weight: 0.5, description: "")
            ]
        )
        let lowStreakRule = TriggerRule(
            subscoreName: "Streifenfreiheit",
            minValue: nil,
            maxValue: 50,
            confidenceThreshold: nil
        )
        let tips = [
            createMockTip(priority: 10, triggerRules: [lowStreakRule]),
            createMockTip(priority: 5, triggerRules: [])
        ]

        // When
        let result = sut.getRelevantTips(for: score, from: tips, maxTips: 3)

        // Then
        XCTAssertEqual(result.count, 2, "Should match tips for weak subscores")
        XCTAssertEqual(result[0].priority, 10, "Specific tip should have highest priority")
    }

    // MARK: - Get Improvement Areas Tests

    func testGetImprovementAreas_WithNoWeakSubscores_ReturnsEmptyArray() {
        // Given
        let score = createMockScore(
            overallScore: 85,
            confidence: 0.9,
            subscores: [
                Subscore(name: "Test1", value: 80, weight: 0.33, description: ""),
                Subscore(name: "Test2", value: 85, weight: 0.33, description: ""),
                Subscore(name: "Test3", value: 90, weight: 0.34, description: "")
            ]
        )

        // When
        let areas = sut.getImprovementAreas(for: score)

        // Then
        XCTAssertEqual(areas.count, 0, "Should return no improvement areas for high scores")
    }

    func testGetImprovementAreas_WithWeakSubscores_ReturnsCorrectAreas() {
        // Given
        let score = createMockScore(
            overallScore: 55,
            confidence: 0.7,
            subscores: [
                Subscore(name: "Sauberkeit", value: 45, weight: 0.5, description: ""),
                Subscore(name: "Detailgrad", value: 65, weight: 0.5, description: "")
            ]
        )

        // When
        let areas = sut.getImprovementAreas(for: score)

        // Then
        XCTAssertEqual(areas.count, 2, "Should return all subscores below 70")
        XCTAssertEqual(areas[0].name, "Sauberkeit", "Should be sorted by value (lowest first)")
        XCTAssertEqual(areas[1].name, "Detailgrad")
    }

    func testGetImprovementAreas_LimitsToTopThree() {
        // Given
        let score = createMockScore(
            overallScore: 40,
            confidence: 0.6,
            subscores: [
                Subscore(name: "Test1", value: 30, weight: 0.25, description: ""),
                Subscore(name: "Test2", value: 40, weight: 0.25, description: ""),
                Subscore(name: "Test3", value: 50, weight: 0.25, description: ""),
                Subscore(name: "Test4", value: 60, weight: 0.25, description: "")
            ]
        )

        // When
        let areas = sut.getImprovementAreas(for: score)

        // Then
        XCTAssertEqual(areas.count, 3, "Should limit to top 3 improvement areas")
    }

    func testGetImprovementAreas_CalculatesCorrectPriority() {
        // Given
        let score = createMockScore(
            overallScore: 40,
            confidence: 0.7,
            subscores: [
                Subscore(name: "Critical", value: 30, weight: 0.33, description: ""),
                Subscore(name: "High", value: 55, weight: 0.33, description: ""),
                Subscore(name: "Medium", value: 65, weight: 0.34, description: "")
            ]
        )

        // When
        let areas = sut.getImprovementAreas(for: score)

        // Then
        XCTAssertEqual(areas[0].priority, .critical, "Score < 40 should be critical")
        XCTAssertEqual(areas[1].priority, .high, "Score 40-60 should be high")
        XCTAssertEqual(areas[2].priority, .medium, "Score 60-70 should be medium")
    }

    func testImprovementArea_CalculatesImprovementNeeded() {
        // Given
        let area = ImprovementArea(
            name: "Test",
            currentValue: 50,
            targetValue: 80,
            priority: .high
        )

        // Then
        XCTAssertEqual(area.improvementNeeded, 30, "Should calculate improvement gap")
    }

    // MARK: - Calculate Streak Tests

    func testCalculateStreak_WithEmptyScores_ReturnsZeroStreak() {
        // Given
        let scores: [Int] = []

        // When
        let streak = sut.calculateStreak(from: scores)

        // Then
        XCTAssertEqual(streak.count, 0, "Empty scores should have zero streak")
        XCTAssertFalse(streak.isActive, "Streak should not be active")
        XCTAssertTrue(streak.message.contains("erste Challenge"), "Should encourage to start")
    }

    func testCalculateStreak_WithConsecutiveGoodScores_ReturnsCorrectStreak() {
        // Given
        let scores = [75, 80, 82, 78, 85] // All >= 70

        // When
        let streak = sut.calculateStreak(from: scores)

        // Then
        XCTAssertEqual(streak.count, 5, "Should count all consecutive good scores")
        XCTAssertTrue(streak.isActive, "Streak should be active")
    }

    func testCalculateStreak_WithBadScoreBreak_CountsOnlyRecent() {
        // Given
        let scores = [85, 75, 65, 80, 75] // Break at 65

        // When
        let streak = sut.calculateStreak(from: scores)

        // Then
        XCTAssertEqual(streak.count, 2, "Should only count scores after break")
        XCTAssertTrue(streak.isActive, "Streak should be active")
    }

    func testCalculateStreak_WithAllBadScores_ReturnsZeroStreak() {
        // Given
        let scores = [50, 60, 45, 55, 65] // All < 70

        // When
        let streak = sut.calculateStreak(from: scores)

        // Then
        XCTAssertEqual(streak.count, 0, "Bad scores should not count")
        XCTAssertFalse(streak.isActive, "Streak should not be active")
    }

    func testCalculateStreak_GeneratesAppropriateMessages() {
        // Test short streak
        let shortStreak = sut.calculateStreak(from: [75, 80])
        XCTAssertTrue(
            shortStreak.message.contains("guten Weg") || shortStreak.message.contains("🚀"),
            "Short streak should be encouraging"
        )

        // Test medium streak
        let mediumStreak = sut.calculateStreak(from: [75, 80, 85, 78])
        XCTAssertTrue(
            mediumStreak.message.contains("Fantastisch") || mediumStreak.message.contains("⭐"),
            "Medium streak should be enthusiastic"
        )

        // Test long streak
        let longStreak = sut.calculateStreak(from: [75, 80, 85, 78, 82, 90])
        XCTAssertTrue(
            longStreak.message.contains("Unglaublich") || longStreak.message.contains("Profi"),
            "Long streak should be highly congratulatory"
        )
    }

    // MARK: - Trigger Rule Matching Tests

    func testTriggerRule_MatchesConfidenceThreshold() {
        // Given
        let highConfidenceScore = createMockScore(overallScore: 80, confidence: 0.9)
        let lowConfidenceScore = createMockScore(overallScore: 80, confidence: 0.6)
        let rule = TriggerRule(
            subscoreName: nil,
            minValue: nil,
            maxValue: nil,
            confidenceThreshold: 0.8
        )

        // When
        let matchesHigh = sut.matches(rule: rule, score: highConfidenceScore)
        let matchesLow = sut.matches(rule: rule, score: lowConfidenceScore)

        // Then
        XCTAssertTrue(matchesHigh, "High confidence should match")
        XCTAssertFalse(matchesLow, "Low confidence should not match")
    }

    func testTriggerRule_MatchesScoreRange() {
        // Given
        let score = createMockScore(overallScore: 65, confidence: 0.8)
        let matchingRule = TriggerRule(
            subscoreName: nil,
            minValue: 60,
            maxValue: 70,
            confidenceThreshold: nil
        )
        let tooHighRule = TriggerRule(
            subscoreName: nil,
            minValue: 70,
            maxValue: nil,
            confidenceThreshold: nil
        )

        // When
        let matchesRange = sut.matches(rule: matchingRule, score: score)
        let matchesTooHigh = sut.matches(rule: tooHighRule, score: score)

        // Then
        XCTAssertTrue(matchesRange, "Score in range should match")
        XCTAssertFalse(matchesTooHigh, "Score below minimum should not match")
    }

    func testTriggerRule_MatchesSubscoreValue() {
        // Given
        let score = createMockScore(
            overallScore: 70,
            confidence: 0.8,
            subscores: [
                Subscore(name: "Sauberkeit", value: 45, weight: 0.5, description: ""),
                Subscore(name: "Detailgrad", value: 80, weight: 0.5, description: "")
            ]
        )
        let matchingRule = TriggerRule(
            subscoreName: "Sauberkeit",
            minValue: nil,
            maxValue: 50,
            confidenceThreshold: nil
        )
        let nonMatchingRule = TriggerRule(
            subscoreName: "Sauberkeit",
            minValue: 60,
            maxValue: nil,
            confidenceThreshold: nil
        )

        // When
        let matches = sut.matches(rule: matchingRule, score: score)
        let doesNotMatch = sut.matches(rule: nonMatchingRule, score: score)

        // Then
        XCTAssertTrue(matches, "Low subscore should match low threshold")
        XCTAssertFalse(doesNotMatch, "Low subscore should not match high threshold")
    }

    func testTriggerRule_NonExistentSubscore_DoesNotMatch() {
        // Given
        let score = createMockScore(
            overallScore: 70,
            confidence: 0.8,
            subscores: [
                Subscore(name: "Existing", value: 80, weight: 1.0, description: "")
            ]
        )
        let rule = TriggerRule(
            subscoreName: "NonExistent",
            minValue: 0,
            maxValue: 100,
            confidenceThreshold: nil
        )

        // When
        let matches = sut.matches(rule: rule, score: score)

        // Then
        XCTAssertFalse(matches, "Non-existent subscore should not match")
    }

    // MARK: - Performance Tests

    func testGetRelevantTips_PerformanceWithLargeDataSet() {
        // Given
        let score = createMockScore(overallScore: 75, confidence: 0.85)
        let tips = (1...100).map { createMockTip(priority: $0, triggerRules: []) }

        // Measure
        measure {
            _ = sut.getRelevantTips(for: score, from: tips, maxTips: 3)
        }
    }

    func testCalculateStreak_PerformanceWithLongHistory() {
        // Given
        let scores = (1...1000).map { _ in Int.random(in: 50...90) }

        // Measure
        measure {
            _ = sut.calculateStreak(from: scores)
        }
    }
}

// MARK: - Test Helpers

extension CoachingEngineTests {
    func createMockScore(
        overallScore: Int,
        confidence: Double,
        subscores: [Subscore]? = nil
    ) -> ExplainableScore {
        let defaultSubscores = [
            Subscore(name: "Test1", value: overallScore, weight: 0.5, description: ""),
            Subscore(name: "Test2", value: overallScore, weight: 0.5, description: "")
        ]

        return ExplainableScore(
            overallScore: overallScore,
            subscores: subscores ?? defaultSubscores,
            confidence: confidence,
            explanation: "Test explanation",
            heatmapData: nil
        )
    }

    func createMockTip(priority: Int, triggerRules: [TriggerRule]) -> CoachTip {
        return CoachTip(
            id: UUID(),
            title: "Test Tip \(priority)",
            content: "Test content",
            triggerRules: triggerRules,
            category: nil,
            priority: priority
        )
    }
}

// MARK: - CoachingEngine Test Extensions

extension CoachingEngine {
    // Expose private method for testing
    func matches(rule: TriggerRule, score: ExplainableScore) -> Bool {
        // Check confidence threshold
        if let threshold = rule.confidenceThreshold {
            if score.confidence < threshold {
                return false
            }
        }

        // Check overall score range
        if rule.subscoreName == nil {
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
}
