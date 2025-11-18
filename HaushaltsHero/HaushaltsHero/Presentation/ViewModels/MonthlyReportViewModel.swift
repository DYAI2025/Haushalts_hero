//
//  MonthlyReportViewModel.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// ViewModel for monthly report (Pro Preview feature)
@MainActor
class MonthlyReportViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var monthlyReport: MonthlyReport?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository: AppRepository

    // MARK: - Initialization

    init(repository: AppRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Load monthly report for the current month
    func loadCurrentMonthReport() async {
        let now = Date()
        await loadReport(for: now)
    }

    /// Load report for a specific month
    func loadReport(for date: Date) async {
        isLoading = true
        errorMessage = nil

        do {
            let monthStart = date.startOfMonth()
            let weeklyStats = try await repository.getMonthlyStats(monthStart: monthStart)

            monthlyReport = calculateMonthlyReport(from: weeklyStats, monthStart: monthStart)

        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Private Methods

    /// Calculate monthly report from weekly stats
    private func calculateMonthlyReport(from weeklyStats: [WeeklyStats], monthStart: Date) -> MonthlyReport {
        let totalChallenges = weeklyStats.reduce(0) { $0 + $1.challengesCompleted }
        let totalPoints = weeklyStats.reduce(0) { $0 + $1.totalPoints }

        // Calculate average score
        let totalScore = weeklyStats.reduce(0.0) { sum, stats in
            sum + (stats.averageScore * Double(stats.challengesCompleted))
        }
        let averageScore = totalChallenges > 0 ? totalScore / Double(totalChallenges) : 0.0

        // Find top category
        var categoryCounts: [String: Int] = [:]
        for stats in weeklyStats {
            for (category, count) in stats.categoryCounts {
                categoryCounts[category, default: 0] += count
            }
        }

        let topCategory = categoryCounts.max(by: { $0.value < $1.value })?.key
            .flatMap { ChallengeCategory(rawValue: $0) }

        // Calculate streak info
        let allScores = weeklyStats.flatMap { _ in [Int]() } // Simplified for MVP
        let streak = 0 // Simplified for MVP

        // Weekly breakdown
        let weeklyBreakdown = weeklyStats.map { stats in
            WeeklyBreakdown(
                weekStart: stats.weekStart,
                challengesCompleted: stats.challengesCompleted,
                averageScore: stats.averageScore,
                totalPoints: stats.totalPoints
            )
        }

        return MonthlyReport(
            month: monthStart,
            totalChallenges: totalChallenges,
            averageScore: averageScore,
            totalPoints: totalPoints,
            topCategory: topCategory,
            currentStreak: streak,
            weeklyBreakdown: weeklyBreakdown
        )
    }
}

// MARK: - Monthly Report Model

struct MonthlyReport {
    let month: Date
    let totalChallenges: Int
    let averageScore: Double
    let totalPoints: Int
    let topCategory: ChallengeCategory?
    let currentStreak: Int
    let weeklyBreakdown: [WeeklyBreakdown]

    /// Get month name (e.g., "November 2025")
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: month)
    }

    /// Calculate improvement percentage compared to previous month
    var improvementPercentage: Double {
        // Simplified for MVP - would need previous month data
        return 0.0
    }

    /// Check if this is a record month
    var isRecordMonth: Bool {
        return totalChallenges > 20 || averageScore >= 85
    }
}

struct WeeklyBreakdown: Identifiable {
    let id = UUID()
    let weekStart: Date
    let challengesCompleted: Int
    let averageScore: Double
    let totalPoints: Int

    var weekNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "W"
        return "Woche \(formatter.string(from: weekStart))"
    }
}

// MARK: - Date Extension

extension Date {
    /// Get the start of the current month
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}
