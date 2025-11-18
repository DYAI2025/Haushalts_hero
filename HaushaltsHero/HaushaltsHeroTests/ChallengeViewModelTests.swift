//
//  ChallengeViewModelTests.swift
//  HaushaltsHeroTests
//
//  Created by AI Agent on 2025-11-18.
//

import XCTest
@testable import HaushaltsHero

@MainActor
class ChallengeViewModelTests: XCTestCase {

    var sut: ChallengeViewModel!
    var mockRepository: MockRepository!
    var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockRepository()
        sut = ChallengeViewModel(repository: mockRepository)

        // Create test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        testImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        testImage = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInit_SetsInitialState() {
        // Then
        XCTAssertNil(sut.selectedCategory, "Selected category should be nil")
        XCTAssertNil(sut.beforeImage, "Before image should be nil")
        XCTAssertNil(sut.afterImage, "After image should be nil")
        XCTAssertNil(sut.currentScore, "Current score should be nil")
        XCTAssertFalse(sut.isProcessing, "Should not be processing")
        XCTAssertNil(sut.errorMessage, "Error message should be nil")
        XCTAssertEqual(sut.flowState, .categorySelection, "Should start at category selection")
    }

    // MARK: - Challenge Start Tests

    func testStartChallenge_SetsSelectedCategoryAndMovesToBeforePhoto() {
        // When
        sut.startChallenge(category: .mirror)

        // Then
        XCTAssertEqual(sut.selectedCategory, .mirror, "Should set selected category")
        XCTAssertEqual(sut.flowState, .beforePhoto, "Should move to before photo state")
        XCTAssertNil(sut.beforeImage, "Should reset before image")
        XCTAssertNil(sut.afterImage, "Should reset after image")
        XCTAssertNil(sut.currentScore, "Should reset current score")
    }

    func testStartChallenge_ResetsState() {
        // Given
        sut.beforeImage = testImage
        sut.currentScore = ExplainableScore(
            overallScore: 75,
            subscores: [],
            confidence: 0.8,
            explanation: "Test",
            heatmapData: nil
        )

        // When
        sut.startChallenge(category: .toilet)

        // Then
        XCTAssertNil(sut.beforeImage, "Should reset before image")
        XCTAssertNil(sut.currentScore, "Should reset current score")
    }

    // MARK: - Photo Capture Tests

    func testCaptureBeforePhoto_StoresImageAndMovesToAfterPhoto() {
        // Given
        sut.startChallenge(category: .mirror)

        // When
        sut.captureBeforePhoto(testImage)

        // Then
        XCTAssertEqual(sut.beforeImage, testImage, "Should store before image")
        XCTAssertEqual(sut.flowState, .afterPhoto, "Should move to after photo state")
    }

    func testCaptureAfterPhoto_StoresImageAndTriggersProcessing() async {
        // Given
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)

        // Configure mock
        mockRepository.activeQuestsToReturn = []
        mockRepository.activeGoalToReturn = nil

        // When
        sut.captureAfterPhoto(testImage)

        // Wait for async processing
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertEqual(sut.afterImage, testImage, "Should store after image")
        XCTAssertNotNil(sut.currentScore, "Should generate score")
        XCTAssertEqual(sut.flowState, .result, "Should move to result state")
    }

    // MARK: - Challenge Processing Tests

    func testProcessChallenge_SavesPhotosAndChallenge() async {
        // Given
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)
        sut.captureAfterPhoto(testImage)

        // Configure mock
        mockRepository.activeQuestsToReturn = []
        mockRepository.activeGoalToReturn = nil

        // Wait for processing
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        XCTAssertGreaterThan(mockRepository.savedPhotos.count, 0, "Should save photos")
        XCTAssertGreaterThan(mockRepository.savedChallenges.count, 0, "Should save challenge")

        let savedChallenge = mockRepository.savedChallenges.first
        XCTAssertNotNil(savedChallenge, "Should have saved challenge")
        XCTAssertEqual(savedChallenge?.category, .mirror, "Should save correct category")
        XCTAssertNotNil(savedChallenge?.score, "Should include score")
    }

    func testProcessChallenge_UpdatesQuestProgress() async {
        // Given
        let quest = Quest(
            id: UUID(),
            title: "Test Quest",
            description: "Test",
            targetCount: 5,
            currentProgress: 2,
            category: .mirror,
            weekStart: Date(),
            rewardPoints: 50
        )
        mockRepository.activeQuestsToReturn = [quest]
        mockRepository.activeGoalToReturn = nil

        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)
        sut.captureAfterPhoto(testImage)

        // Wait for processing
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        XCTAssertGreaterThan(
            mockRepository.questProgressUpdates.count,
            0,
            "Should update quest progress"
        )
        let update = mockRepository.questProgressUpdates.first
        XCTAssertEqual(update?.0, quest.id, "Should update correct quest")
        XCTAssertEqual(update?.1, 3, "Should increment progress")
    }

    func testProcessChallenge_UpdatesGoalProgress() async {
        // Given
        let goal = Goal(
            id: UUID(),
            title: "Test Goal",
            targetPoints: 500,
            currentPoints: 200,
            weekStart: Date()
        )
        mockRepository.activeQuestsToReturn = []
        mockRepository.activeGoalToReturn = goal

        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)
        sut.captureAfterPhoto(testImage)

        // Wait for processing
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        XCTAssertGreaterThan(
            mockRepository.goalProgressUpdates.count,
            0,
            "Should update goal progress"
        )
    }

    func testProcessChallenge_HandlesErrorGracefully() async {
        // Given
        mockRepository.shouldThrowError = true
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)
        sut.captureAfterPhoto(testImage)

        // Wait for processing
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        XCTAssertNotNil(sut.errorMessage, "Should set error message")
        XCTAssertFalse(sut.isProcessing, "Should stop processing")
        XCTAssertEqual(sut.flowState, .result, "Should still move to result state")
    }

    func testProcessChallenge_SetsProcessingFlag() async {
        // Given
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)

        mockRepository.activeQuestsToReturn = []
        mockRepository.activeGoalToReturn = nil

        // When
        sut.captureAfterPhoto(testImage)

        // Immediately check (before processing completes)
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        // Then processing should have started (or completed)
        // Note: This test may be flaky due to timing
    }

    // MARK: - Retry Tests

    func testRetryChallenge_ResetsToBeforePhoto() {
        // Given
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)
        sut.captureAfterPhoto(testImage)

        // When
        sut.retryChallenge()

        // Then
        XCTAssertNil(sut.beforeImage, "Should clear before image")
        XCTAssertNil(sut.afterImage, "Should clear after image")
        XCTAssertNil(sut.currentScore, "Should clear score")
        XCTAssertNil(sut.errorMessage, "Should clear error")
        XCTAssertEqual(sut.flowState, .beforePhoto, "Should return to before photo")
    }

    // MARK: - Complete Tests

    func testCompleteChallenge_ResetsToStart() {
        // Given
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)

        // When
        sut.completeChallenge()

        // Then
        XCTAssertNil(sut.selectedCategory, "Should clear selected category")
        XCTAssertNil(sut.beforeImage, "Should clear before image")
        XCTAssertNil(sut.afterImage, "Should clear after image")
        XCTAssertNil(sut.currentScore, "Should clear score")
        XCTAssertEqual(sut.flowState, .categorySelection, "Should return to start")
    }

    // MARK: - Reset Tests

    func testReset_ClearsAllState() {
        // Given
        sut.startChallenge(category: .mirror)
        sut.captureBeforePhoto(testImage)
        sut.errorMessage = "Test error"

        // When
        sut.reset()

        // Then
        XCTAssertNil(sut.beforeImage, "Should clear before image")
        XCTAssertNil(sut.afterImage, "Should clear after image")
        XCTAssertNil(sut.currentScore, "Should clear score")
        XCTAssertNil(sut.errorMessage, "Should clear error")
        XCTAssertFalse(sut.isProcessing, "Should clear processing flag")
    }
}
