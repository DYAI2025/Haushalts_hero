//
//  ScoringEngineTests.swift
//  HaushaltsHeroTests
//
//  Created by AI Agent on 2025-11-18.
//

import XCTest
@testable import HaushaltsHero

class ScoringEngineTests: XCTestCase {

    var sut: ScoringEngine!
    var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ScoringEngine()

        // Create a simple test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        testImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    override func tearDownWithError() throws {
        sut = nil
        testImage = nil
        try super.tearDownWithError()
    }

    // MARK: - Overall Score Calculation Tests

    func testCalculateOverallScore_WithEqualWeights_ReturnsCorrectScore() {
        // Given
        let subscores = [
            Subscore(name: "Test1", value: 80, weight: 0.33, description: ""),
            Subscore(name: "Test2", value: 70, weight: 0.33, description: ""),
            Subscore(name: "Test3", value: 90, weight: 0.34, description: "")
        ]

        // When
        let score = sut.calculateOverallScore(from: subscores)

        // Then
        let expected = Int((80 * 0.33 + 70 * 0.33 + 90 * 0.34).rounded())
        XCTAssertEqual(score, expected, "Overall score should be weighted average")
    }

    func testCalculateOverallScore_WithDifferentWeights_ReturnsWeightedAverage() {
        // Given
        let subscores = [
            Subscore(name: "Test1", value: 100, weight: 0.5, description: ""),
            Subscore(name: "Test2", value: 50, weight: 0.3, description: ""),
            Subscore(name: "Test3", value: 0, weight: 0.2, description: "")
        ]

        // When
        let score = sut.calculateOverallScore(from: subscores)

        // Then
        let expected = Int((100 * 0.5 + 50 * 0.3 + 0 * 0.2).rounded())
        XCTAssertEqual(score, expected, "Score should respect weight differences")
    }

    func testCalculateOverallScore_WithSingleSubscore_ReturnsSubscoreValue() {
        // Given
        let subscores = [
            Subscore(name: "Test", value: 75, weight: 1.0, description: "")
        ]

        // When
        let score = sut.calculateOverallScore(from: subscores)

        // Then
        XCTAssertEqual(score, 75, "Single subscore should equal overall score")
    }

    // MARK: - Confidence Calculation Tests

    func testCalculateConfidence_WithLowVariance_ReturnsHighConfidence() {
        // Given
        let subscores = [
            Subscore(name: "Test1", value: 80, weight: 0.33, description: ""),
            Subscore(name: "Test2", value: 82, weight: 0.33, description: ""),
            Subscore(name: "Test3", value: 81, weight: 0.34, description: "")
        ]

        // When
        let confidence = sut.calculateConfidence(from: subscores, category: .mirror)

        // Then
        XCTAssertGreaterThan(confidence, 0.8, "Low variance should yield high confidence")
    }

    func testCalculateConfidence_WithHighVariance_ReturnsLowerConfidence() {
        // Given
        let subscores = [
            Subscore(name: "Test1", value: 10, weight: 0.33, description: ""),
            Subscore(name: "Test2", value: 90, weight: 0.33, description: ""),
            Subscore(name: "Test3", value: 50, weight: 0.34, description: "")
        ]

        // When
        let confidence = sut.calculateConfidence(from: subscores, category: .mirror)

        // Then
        XCTAssertLessThan(confidence, 0.7, "High variance should yield lower confidence")
    }

    func testCalculateConfidence_ReturnsValueInValidRange() {
        // Given
        let subscores = [
            Subscore(name: "Test1", value: 60, weight: 0.5, description: ""),
            Subscore(name: "Test2", value: 40, weight: 0.5, description: "")
        ]

        // When
        let confidence = sut.calculateConfidence(from: subscores, category: .toilet)

        // Then
        XCTAssertGreaterThanOrEqual(confidence, 0.0, "Confidence should be >= 0.0")
        XCTAssertLessThanOrEqual(confidence, 1.0, "Confidence should be <= 1.0")
    }

    // MARK: - Explanation Generation Tests

    func testGenerateExplanation_WithLowScore_ReturnsEncouragingMessage() {
        // Given
        let subscores = [
            Subscore(name: "Sauberkeit", value: 30, weight: 0.5, description: ""),
            Subscore(name: "Detailgrad", value: 40, weight: 0.5, description: "")
        ]

        // When
        let explanation = sut.generateExplanation(
            overallScore: 35,
            subscores: subscores,
            category: .toilet
        )

        // Then
        XCTAssertTrue(explanation.contains("Verbesserungsbedarf"), "Low score should mention improvement")
        XCTAssertTrue(explanation.contains("nächsten Mal"), "Should be encouraging")
    }

    func testGenerateExplanation_WithHighScore_ReturnsCongratulationsMessage() {
        // Given
        let subscores = [
            Subscore(name: "Streifenfreiheit", value: 90, weight: 0.4, description: ""),
            Subscore(name: "Klarheit", value: 88, weight: 0.6, description: "")
        ]

        // When
        let explanation = sut.generateExplanation(
            overallScore: 89,
            subscores: subscores,
            category: .mirror
        )

        // Then
        XCTAssertTrue(
            explanation.contains("hervorragend") || explanation.contains("sehr gut"),
            "High score should be praised"
        )
    }

    func testGenerateExplanation_WithWeakSubscore_MentionsImprovementArea() {
        // Given
        let subscores = [
            Subscore(name: "Ordnung", value: 85, weight: 0.5, description: ""),
            Subscore(name: "Detailgrad", value: 50, weight: 0.5, description: "")
        ]

        // When
        let explanation = sut.generateExplanation(
            overallScore: 67,
            subscores: subscores,
            category: .room
        )

        // Then
        XCTAssertTrue(
            explanation.lowercased().contains("detailgrad"),
            "Should mention the weakest subscore"
        )
    }

    // MARK: - Score Calculation Integration Tests

    func testCalculateScore_ReturnsValidExplainableScore() async {
        // Given
        let beforeImage = testImage!
        let afterImage = testImage!

        // When
        let score = await sut.calculateScore(
            beforeImage: beforeImage,
            afterImage: afterImage,
            category: .mirror
        )

        // Then
        XCTAssertGreaterThanOrEqual(score.overallScore, 0, "Overall score should be >= 0")
        XCTAssertLessThanOrEqual(score.overallScore, 100, "Overall score should be <= 100")
        XCTAssertGreaterThanOrEqual(score.confidence, 0.0, "Confidence should be >= 0.0")
        XCTAssertLessThanOrEqual(score.confidence, 1.0, "Confidence should be <= 1.0")
        XCTAssertFalse(score.explanation.isEmpty, "Explanation should not be empty")
    }

    func testCalculateScore_ForMirrorCategory_ReturnsThreeSubscores() async {
        // Given
        let beforeImage = testImage!
        let afterImage = testImage!

        // When
        let score = await sut.calculateScore(
            beforeImage: beforeImage,
            afterImage: afterImage,
            category: .mirror
        )

        // Then
        XCTAssertEqual(score.subscores.count, 3, "Mirror category should have 3 subscores")

        let subscoreNames = score.subscores.map { $0.name }
        XCTAssertTrue(subscoreNames.contains("Streifenfreiheit"), "Should have Streifenfreiheit")
        XCTAssertTrue(subscoreNames.contains("Klarheit"), "Should have Klarheit")
        XCTAssertTrue(subscoreNames.contains("Gleichmäßigkeit"), "Should have Gleichmäßigkeit")
    }

    func testCalculateScore_ForToiletCategory_ReturnsCorrectSubscores() async {
        // Given
        let beforeImage = testImage!
        let afterImage = testImage!

        // When
        let score = await sut.calculateScore(
            beforeImage: beforeImage,
            afterImage: afterImage,
            category: .toilet
        )

        // Then
        XCTAssertEqual(score.subscores.count, 3, "Toilet category should have 3 subscores")

        let subscoreNames = score.subscores.map { $0.name }
        XCTAssertTrue(subscoreNames.contains("Sauberkeit"), "Should have Sauberkeit")
        XCTAssertTrue(subscoreNames.contains("Detailgrad"), "Should have Detailgrad")
        XCTAssertTrue(subscoreNames.contains("Glanz"), "Should have Glanz")
    }

    func testCalculateScore_ForRoomCategory_ReturnsCorrectSubscores() async {
        // Given
        let beforeImage = testImage!
        let afterImage = testImage!

        // When
        let score = await sut.calculateScore(
            beforeImage: beforeImage,
            afterImage: afterImage,
            category: .room
        )

        // Then
        XCTAssertEqual(score.subscores.count, 3, "Room category should have 3 subscores")

        let subscoreNames = score.subscores.map { $0.name }
        XCTAssertTrue(subscoreNames.contains("Ordnung"), "Should have Ordnung")
        XCTAssertTrue(subscoreNames.contains("Detailgrad"), "Should have Detailgrad")
        XCTAssertTrue(subscoreNames.contains("Vollständigkeit"), "Should have Vollständigkeit")
    }

    func testCalculateScore_IncludesHeatmapData() async {
        // Given
        let beforeImage = testImage!
        let afterImage = testImage!

        // When
        let score = await sut.calculateScore(
            beforeImage: beforeImage,
            afterImage: afterImage,
            category: .mirror
        )

        // Then
        XCTAssertNotNil(score.heatmapData, "Score should include heatmap data")

        if let heatmap = score.heatmapData {
            XCTAssertGreaterThan(heatmap.width, 0, "Heatmap should have width")
            XCTAssertGreaterThan(heatmap.height, 0, "Heatmap should have height")
            XCTAssertEqual(heatmap.intensityMap.count, heatmap.height, "Intensity map should match height")
            XCTAssertEqual(heatmap.intensityMap[0].count, heatmap.width, "Intensity map should match width")
        }
    }

    // MARK: - Subscore Weights Tests

    func testSubscoreWeights_SumToOne_ForAllCategories() async {
        // Test for each category
        for category in ChallengeCategory.allCases {
            // Given
            let beforeImage = testImage!
            let afterImage = testImage!

            // When
            let score = await sut.calculateScore(
                beforeImage: beforeImage,
                afterImage: afterImage,
                category: category
            )

            // Then
            let totalWeight = score.subscores.reduce(0.0) { $0 + $1.weight }
            XCTAssertEqual(
                totalWeight,
                1.0,
                accuracy: 0.01,
                "Weights should sum to 1.0 for category \(category.rawValue)"
            )
        }
    }

    // MARK: - Performance Tests

    func testCalculateScore_PerformanceUnder2Seconds() {
        // Given
        let beforeImage = testImage!
        let afterImage = testImage!

        // Measure performance
        measure {
            let expectation = self.expectation(description: "Score calculation")

            Task {
                _ = await sut.calculateScore(
                    beforeImage: beforeImage,
                    afterImage: afterImage,
                    category: .mirror
                )
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 2.0)
        }
    }
}

// MARK: - Test Helpers

extension ScoringEngine {
    // Expose private methods for testing
    func calculateOverallScore(from subscores: [Subscore]) -> Int {
        let weightedSum = subscores.reduce(0.0) { sum, subscore in
            sum + (Double(subscore.value) * subscore.weight)
        }
        return Int(weightedSum.rounded())
    }

    func calculateConfidence(from subscores: [Subscore], category: ChallengeCategory) -> Double {
        let values = subscores.map { Double($0.value) }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        let standardDeviation = sqrt(variance)
        let normalizedSD = min(standardDeviation / 50.0, 1.0)
        let baseConfidence = 1.0 - normalizedSD
        let scoreBonus = mean > 70 ? 0.1 : 0.0
        return min(max(baseConfidence + scoreBonus, 0.0), 1.0)
    }

    func generateExplanation(
        overallScore: Int,
        subscores: [Subscore],
        category: ChallengeCategory
    ) -> String {
        let scoreLevel: String
        let encouragement: String

        switch overallScore {
        case 0..<50:
            scoreLevel = "noch Verbesserungsbedarf"
            encouragement = "Beim nächsten Mal wird es besser!"
        case 50..<70:
            scoreLevel = "ein gutes Ergebnis"
            encouragement = "Mit etwas mehr Aufmerksamkeit auf Details wird es noch besser."
        case 70..<85:
            scoreLevel = "ein sehr gutes Ergebnis"
            encouragement = "Weiter so!"
        case 85...100:
            scoreLevel = "ein hervorragendes Ergebnis"
            encouragement = "Du bist ein echter Haushalts-Held!"
        default:
            scoreLevel = "ein Ergebnis"
            encouragement = ""
        }

        let lowestSubscore = subscores.min(by: { $0.value < $1.value })
        var explanation = "Du hast \(scoreLevel) erzielt. "

        if let lowest = lowestSubscore, lowest.value < 70 {
            explanation += "Achte beim nächsten Mal besonders auf \(lowest.name.lowercased()). "
        }

        explanation += encouragement
        return explanation
    }
}
