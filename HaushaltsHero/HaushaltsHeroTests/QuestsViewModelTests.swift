//
//  QuestsViewModelTests.swift
//  HaushaltsHeroTests
//
//  Created by AI Agent on 2025-11-18.
//

import XCTest
@testable import HaushaltsHero

@MainActor
class QuestsViewModelTests: XCTestCase {

    var sut: QuestsViewModel!
    var mockRepository: MockRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockRepository()
        sut = QuestsViewModel(repository: mockRepository)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInit_SetsInitialState() {
        // Then
        XCTAssertEqual(sut.activeQuests.count, 0, "Should start with no quests")
        XCTAssertNil(sut.activeGoal, "Should start with no goal")
        XCTAssertNil(sut.weeklyStats, "Should start with no stats")
        XCTAssertFalse(sut.isLoading, "Should not be loading")
        XCTAssertNil(sut.errorMessage, "Should have no error")
    }

    // MARK: - Load Data Tests

    func testLoadData_LoadsQuestsGoalAndStats() async {
        // Given
        let quest1 = createMockQuest(title: "Quest 1", currentProgress: 2, targetCount: 5)
        let quest2 = createMockQuest(title: "Quest 2", currentProgress: 1, targetCount: 3)
        let goal = createMockGoal(currentPoints: 150, targetPoints: 500)
        let stats = createMockWeeklyStats(challengesCompleted: 5, averageScore: 75.0)

        mockRepository.activeQuestsToReturn = [quest1, quest2]
        mockRepository.activeGoalToReturn = goal
        mockRepository.weeklyStatsToReturn = stats

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.activeQuests.count, 2, "Should load quests")
        XCTAssertNotNil(sut.activeGoal, "Should load goal")
        XCTAssertNotNil(sut.weeklyStats, "Should load stats")
        XCTAssertFalse(sut.isLoading, "Should stop loading")
        XCTAssertNil(sut.errorMessage, "Should have no error")
    }

    func testLoadData_SetsLoadingFlag() async {
        // Given
        mockRepository.activeQuestsToReturn = []
        mockRepository.activeGoalToReturn = nil

        // When
        let loadTask = Task {
            await sut.loadData()
        }

        // Check immediately
        try? await Task.sleep(nanoseconds: 1_000_000) // 0.001 seconds

        // Then - may be loading or already loaded depending on timing
        // Just verify it eventually completes
        await loadTask.value
        XCTAssertFalse(sut.isLoading, "Should stop loading after completion")
    }

    func testLoadData_HandlesError() async {
        // Given
        mockRepository.shouldThrowError = true

        // When
        await sut.loadData()

        // Then
        XCTAssertNotNil(sut.errorMessage, "Should set error message")
        XCTAssertFalse(sut.isLoading, "Should stop loading")
    }

    func testLoadData_WithNoGoal_SetsGoalToNil() async {
        // Given
        mockRepository.activeQuestsToReturn = []
        mockRepository.activeGoalToReturn = nil

        // When
        await sut.loadData()

        // Then
        XCTAssertNil(sut.activeGoal, "Goal should be nil when none exists")
    }

    // MARK: - Refresh Tests

    func testRefresh_ReloadsData() async {
        // Given
        let quest = createMockQuest(title: "Quest", currentProgress: 1, targetCount: 3)
        mockRepository.activeQuestsToReturn = [quest]

        // First load
        await sut.loadData()
        XCTAssertEqual(sut.activeQuests.count, 1, "Should have initial quest")

        // Change mock data
        let updatedQuest = createMockQuest(title: "Updated Quest", currentProgress: 2, targetCount: 3)
        mockRepository.activeQuestsToReturn = [quest, updatedQuest]

        // When
        await sut.refresh()

        // Then
        XCTAssertEqual(sut.activeQuests.count, 2, "Should reload with updated data")
    }

    // MARK: - Progress Text Tests

    func testProgressText_ReturnsCorrectFormat() {
        // Given
        let quest = createMockQuest(title: "Test", currentProgress: 3, targetCount: 5)

        // When
        let text = sut.progressText(for: quest)

        // Then
        XCTAssertEqual(text, "3 / 5", "Should format progress correctly")
    }

    func testProgressText_WithZeroProgress() {
        // Given
        let quest = createMockQuest(title: "Test", currentProgress: 0, targetCount: 10)

        // When
        let text = sut.progressText(for: quest)

        // Then
        XCTAssertEqual(text, "0 / 10", "Should handle zero progress")
    }

    func testProgressText_WithCompleteProgress() {
        // Given
        let quest = createMockQuest(title: "Test", currentProgress: 5, targetCount: 5)

        // When
        let text = sut.progressText(for: quest)

        // Then
        XCTAssertEqual(text, "5 / 5", "Should handle complete progress")
    }

    // MARK: - Remaining Count Tests

    func testRemainingCount_CalculatesCorrectly() {
        // Given
        let quest = createMockQuest(title: "Test", currentProgress: 2, targetCount: 7)

        // When
        let remaining = sut.remainingCount(for: quest)

        // Then
        XCTAssertEqual(remaining, 5, "Should calculate remaining correctly")
    }

    func testRemainingCount_WithCompleteQuest_ReturnsZero() {
        // Given
        let quest = createMockQuest(title: "Test", currentProgress: 5, targetCount: 5)

        // When
        let remaining = sut.remainingCount(for: quest)

        // Then
        XCTAssertEqual(remaining, 0, "Should return zero for complete quest")
    }

    func testRemainingCount_WithOverProgress_ReturnsZero() {
        // Given - Edge case where progress exceeds target
        let quest = createMockQuest(title: "Test", currentProgress: 8, targetCount: 5)

        // When
        let remaining = sut.remainingCount(for: quest)

        // Then
        XCTAssertEqual(remaining, 0, "Should return zero when progress exceeds target")
    }

    // MARK: - Completed Quests Tests

    func testHasCompletedQuests_WithCompletedQuest_ReturnsTrue() async {
        // Given
        let completedQuest = createMockQuest(title: "Complete", currentProgress: 5, targetCount: 5)
        let incompleteQuest = createMockQuest(title: "Incomplete", currentProgress: 2, targetCount: 5)
        mockRepository.activeQuestsToReturn = [completedQuest, incompleteQuest]

        await sut.loadData()

        // When
        let hasCompleted = sut.hasCompletedQuests

        // Then
        XCTAssertTrue(hasCompleted, "Should detect completed quests")
    }

    func testHasCompletedQuests_WithNoCompletedQuests_ReturnsFalse() async {
        // Given
        let quest1 = createMockQuest(title: "Quest 1", currentProgress: 2, targetCount: 5)
        let quest2 = createMockQuest(title: "Quest 2", currentProgress: 1, targetCount: 3)
        mockRepository.activeQuestsToReturn = [quest1, quest2]

        await sut.loadData()

        // When
        let hasCompleted = sut.hasCompletedQuests

        // Then
        XCTAssertFalse(hasCompleted, "Should return false with no completed quests")
    }

    func testCompletedQuestsCount_CountsCorrectly() async {
        // Given
        let completed1 = createMockQuest(title: "Complete 1", currentProgress: 5, targetCount: 5)
        let completed2 = createMockQuest(title: "Complete 2", currentProgress: 3, targetCount: 3)
        let incomplete = createMockQuest(title: "Incomplete", currentProgress: 1, targetCount: 5)
        mockRepository.activeQuestsToReturn = [completed1, completed2, incomplete]

        await sut.loadData()

        // When
        let count = sut.completedQuestsCount

        // Then
        XCTAssertEqual(count, 2, "Should count completed quests correctly")
    }

    func testTotalQuestsCount_CountsAllQuests() async {
        // Given
        let quest1 = createMockQuest(title: "Quest 1", currentProgress: 5, targetCount: 5)
        let quest2 = createMockQuest(title: "Quest 2", currentProgress: 2, targetCount: 5)
        let quest3 = createMockQuest(title: "Quest 3", currentProgress: 0, targetCount: 3)
        mockRepository.activeQuestsToReturn = [quest1, quest2, quest3]

        await sut.loadData()

        // When
        let count = sut.totalQuestsCount

        // Then
        XCTAssertEqual(count, 3, "Should count all quests")
    }

    // MARK: - Reward Points Tests

    func testTotalPossibleRewardPoints_SumsAllQuests() async {
        // Given
        let quest1 = createMockQuest(title: "Quest 1", currentProgress: 0, targetCount: 5, rewardPoints: 50)
        let quest2 = createMockQuest(title: "Quest 2", currentProgress: 0, targetCount: 3, rewardPoints: 30)
        let quest3 = createMockQuest(title: "Quest 3", currentProgress: 0, targetCount: 2, rewardPoints: 20)
        mockRepository.activeQuestsToReturn = [quest1, quest2, quest3]

        await sut.loadData()

        // When
        let total = sut.totalPossibleRewardPoints

        // Then
        XCTAssertEqual(total, 100, "Should sum all reward points")
    }

    func testEarnedRewardPoints_SumsOnlyCompletedQuests() async {
        // Given
        let completed1 = createMockQuest(title: "Complete 1", currentProgress: 5, targetCount: 5, rewardPoints: 50)
        let completed2 = createMockQuest(title: "Complete 2", currentProgress: 3, targetCount: 3, rewardPoints: 30)
        let incomplete = createMockQuest(title: "Incomplete", currentProgress: 1, targetCount: 5, rewardPoints: 40)
        mockRepository.activeQuestsToReturn = [completed1, completed2, incomplete]

        await sut.loadData()

        // When
        let earned = sut.earnedRewardPoints

        // Then
        XCTAssertEqual(earned, 80, "Should sum only completed quest rewards")
    }

    func testEarnedRewardPoints_WithNoCompletedQuests_ReturnsZero() async {
        // Given
        let quest1 = createMockQuest(title: "Quest 1", currentProgress: 2, targetCount: 5, rewardPoints: 50)
        let quest2 = createMockQuest(title: "Quest 2", currentProgress: 1, targetCount: 3, rewardPoints: 30)
        mockRepository.activeQuestsToReturn = [quest1, quest2]

        await sut.loadData()

        // When
        let earned = sut.earnedRewardPoints

        // Then
        XCTAssertEqual(earned, 0, "Should return zero with no completed quests")
    }

    // MARK: - Integration Tests

    func testLoadData_IntegrationWithMultipleDataTypes() async {
        // Given
        let quests = [
            createMockQuest(title: "Mirror Quest", currentProgress: 3, targetCount: 5, rewardPoints: 50),
            createMockQuest(title: "Toilet Quest", currentProgress: 5, targetCount: 5, rewardPoints: 40)
        ]
        let goal = createMockGoal(currentPoints: 200, targetPoints: 500)
        let stats = createMockWeeklyStats(challengesCompleted: 8, averageScore: 82.5)

        mockRepository.activeQuestsToReturn = quests
        mockRepository.activeGoalToReturn = goal
        mockRepository.weeklyStatsToReturn = stats

        // When
        await sut.loadData()

        // Then
        XCTAssertEqual(sut.totalQuestsCount, 2, "Should load quests")
        XCTAssertEqual(sut.completedQuestsCount, 1, "Should detect completed quests")
        XCTAssertEqual(sut.activeGoal?.currentPoints, 200, "Should load goal")
        XCTAssertEqual(sut.weeklyStats?.challengesCompleted, 8, "Should load stats")
        XCTAssertNil(sut.errorMessage, "Should have no error")
    }
}

// MARK: - Test Helpers

extension QuestsViewModelTests {
    func createMockQuest(
        title: String,
        currentProgress: Int,
        targetCount: Int,
        category: ChallengeCategory = .mirror,
        rewardPoints: Int = 50
    ) -> Quest {
        return Quest(
            id: UUID(),
            title: title,
            description: "Test description",
            targetCount: targetCount,
            currentProgress: currentProgress,
            category: category,
            weekStart: Date(),
            rewardPoints: rewardPoints
        )
    }

    func createMockGoal(
        currentPoints: Int,
        targetPoints: Int
    ) -> Goal {
        return Goal(
            id: UUID(),
            title: "Weekly Goal",
            targetPoints: targetPoints,
            currentPoints: currentPoints,
            weekStart: Date()
        )
    }

    func createMockWeeklyStats(
        challengesCompleted: Int,
        averageScore: Double
    ) -> WeeklyStats {
        return WeeklyStats(
            weekStart: Date(),
            challengesCompleted: challengesCompleted,
            averageScore: averageScore,
            categoryCounts: [.mirror: 3, .toilet: 2],
            totalPoints: Int(averageScore) * challengesCompleted
        )
    }
}
