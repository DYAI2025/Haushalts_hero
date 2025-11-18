//
//  HabitCoachViewModel.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// ViewModel for Habit Coach
@MainActor
class HabitCoachViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var weeklyStats: WeeklyStats?
    @Published var recentChallenges: [Challenge] = []
    @Published var personalGoals: [PersonalGoal] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingGoalEditor: Bool = false

    // MARK: - Dependencies

    private let repository: AppRepository

    // MARK: - Initialization

    init(repository: AppRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Load all habit coach data
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load weekly stats
            let weekStart = Date.startOfCurrentWeek()
            weeklyStats = try await repository.getWeeklyStats(weekStart: weekStart)

            // Load recent challenges
            recentChallenges = try await repository.getChallengesForWeek(startDate: weekStart)

            // Load personal goals from settings (simplified for MVP)
            loadPersonalGoals()

        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Add a new personal goal
    func addGoal(_ goal: PersonalGoal) {
        personalGoals.append(goal)
        savePersonalGoals()
    }

    /// Toggle goal completion
    func toggleGoalCompletion(goalId: UUID) {
        if let index = personalGoals.firstIndex(where: { $0.id == goalId }) {
            personalGoals[index].isCompleted.toggle()
            savePersonalGoals()
        }
    }

    /// Remove a goal
    func removeGoal(goalId: UUID) {
        personalGoals.removeAll { $0.id == goalId }
        savePersonalGoals()
    }

    /// Get motivation message based on performance
    func getMotivationMessage() -> String {
        guard let stats = weeklyStats else {
            return "Starte deine erste Challenge dieser Woche!"
        }

        if stats.challengesCompleted == 0 {
            return "Zeit für deine erste Challenge! 💪"
        } else if stats.challengesCompleted >= 10 {
            return "Wow! Du bist ein echter Haushalts-Held! 🌟"
        } else if stats.challengesCompleted >= 5 {
            return "Fantastisch! Du machst tolle Fortschritte! 🚀"
        } else if stats.averageScore >= 80 {
            return "Exzellente Qualität! Weiter so! ⭐"
        } else {
            return "Guter Start! Bleib dran! 💫"
        }
    }

    /// Get week day name for a challenge
    func weekDay(for challenge: Challenge) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: challenge.timestamp)
    }

    /// Get completion percentage for personal goals
    var personalGoalsCompletionPercentage: Int {
        guard !personalGoals.isEmpty else { return 0 }
        let completed = personalGoals.filter { $0.isCompleted }.count
        return (completed * 100) / personalGoals.count
    }

    // MARK: - Private Methods

    /// Load personal goals from UserDefaults (simplified for MVP)
    private func loadPersonalGoals() {
        // For MVP: Use hardcoded default goals
        // In production: Load from repository/settings
        personalGoals = [
            PersonalGoal(
                title: "Täglich eine Challenge",
                description: "Mindestens eine Challenge pro Tag",
                targetPerWeek: 7,
                isCompleted: false
            ),
            PersonalGoal(
                title: "Durchschnitt über 75",
                description: "Halte deinen Wochen-Durchschnitt über 75 Punkten",
                targetPerWeek: 1,
                isCompleted: (weeklyStats?.averageScore ?? 0) >= 75
            ),
            PersonalGoal(
                title: "Alle Kategorien nutzen",
                description: "Probiere alle Challenge-Kategorien aus",
                targetPerWeek: 3,
                isCompleted: (weeklyStats?.categoryCounts.count ?? 0) >= 3
            )
        ]
    }

    /// Save personal goals to UserDefaults (simplified for MVP)
    private func savePersonalGoals() {
        // For MVP: Just keep in memory
        // In production: Save to repository
    }
}

// MARK: - Personal Goal Model

struct PersonalGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let targetPerWeek: Int
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetPerWeek: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetPerWeek = targetPerWeek
        self.isCompleted = isCompleted
    }
}
