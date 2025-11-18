//
//  HabitCoachView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for habit coaching and weekly overview
struct HabitCoachView: View {

    // MARK: - Properties

    @StateObject private var viewModel: HabitCoachViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Initialization

    init(repository: AppRepository) {
        _viewModel = StateObject(wrappedValue: HabitCoachViewModel(repository: repository))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Lädt...")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Motivation Header
                            MotivationCard(viewModel: viewModel)

                            // Weekly Stats Overview
                            if let stats = viewModel.weeklyStats {
                                WeeklyOverviewCard(stats: stats)
                            }

                            // Week Calendar
                            WeekCalendarView(
                                challenges: viewModel.recentChallenges,
                                viewModel: viewModel
                            )

                            // Personal Goals
                            PersonalGoalsSection(viewModel: viewModel)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Habit Coach")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.loadData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Motivation Card

struct MotivationCard: View {
    @ObservedObject var viewModel: HabitCoachViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Dein Fortschritt")
                        .font(.headline)

                    Text(viewModel.getMotivationMessage())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Weekly Overview Card

struct WeeklyOverviewCard: View {
    let stats: WeeklyStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Diese Woche")
                .font(.headline)

            HStack(spacing: 16) {
                OverviewItem(
                    icon: "checkmark.circle.fill",
                    value: "\(stats.challengesCompleted)",
                    label: "Challenges",
                    color: .green
                )

                OverviewItem(
                    icon: "star.fill",
                    value: String(format: "%.0f", stats.averageScore),
                    label: "Ø Score",
                    color: .orange
                )

                OverviewItem(
                    icon: "trophy.fill",
                    value: "\(stats.totalPoints)",
                    label: "Punkte",
                    color: .purple
                )
            }

            // Top Category
            if let topCategory = stats.topCategory {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text("Top-Kategorie: \(topCategory.description)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8)
        )
        .padding(.horizontal)
    }
}

struct OverviewItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Week Calendar View

struct WeekCalendarView: View {
    let challenges: [Challenge]
    @ObservedObject var viewModel: HabitCoachViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wochenkalender")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    WeekDayRow(
                        day: day,
                        challenges: challengesForDay(day),
                        viewModel: viewModel
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8)
            )
            .padding(.horizontal)
        }
    }

    private var weekDays: [Date] {
        let weekStart = Date.startOfCurrentWeek()
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    private func challengesForDay(_ day: Date) -> [Challenge] {
        challenges.filter { challenge in
            Calendar.current.isDate(challenge.timestamp, inSameDayAs: day)
        }
    }
}

struct WeekDayRow: View {
    let day: Date
    let challenges: [Challenge]
    @ObservedObject var viewModel: HabitCoachViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Day Label
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isToday ? .blue : .secondary)

                Text(dayNumber)
                    .font(.title3)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isToday ? .blue : .primary)
            }
            .frame(width: 50)

            // Challenges
            if challenges.isEmpty {
                HStack {
                    Image(systemName: "circle.dashed")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.caption)

                    Text("Keine Challenge")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(challenges) { challenge in
                            ChallengeDot(challenge: challenge)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: day).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(day)
    }
}

struct ChallengeDot: View {
    let challenge: Challenge

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: categoryIcon)
                    .foregroundColor(categoryColor)
                    .font(.caption)
            }

            if let score = challenge.score {
                Text("\(score.overallScore)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor(score.overallScore))
            }
        }
    }

    private var categoryColor: Color {
        switch challenge.category {
        case .mirror: return .blue
        case .toilet: return .cyan
        case .room: return .indigo
        }
    }

    private var categoryIcon: String {
        switch challenge.category {
        case .mirror: return "mirror"
        case .toilet: return "drop.circle"
        case .room: return "bed.double"
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 85...100: return .green
        case 70..<85: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}

// MARK: - Personal Goals Section

struct PersonalGoalsSection: View {
    @ObservedObject var viewModel: HabitCoachViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Persönliche Ziele")
                    .font(.headline)

                Spacer()

                if !viewModel.personalGoals.isEmpty {
                    Text("\(viewModel.personalGoalsCompletionPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)

            if viewModel.personalGoals.isEmpty {
                EmptyGoalsView()
                    .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.personalGoals) { goal in
                        PersonalGoalRow(goal: goal, viewModel: viewModel)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 8)
                )
                .padding(.horizontal)
            }
        }
    }
}

struct PersonalGoalRow: View {
    let goal: PersonalGoal
    @ObservedObject var viewModel: HabitCoachViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                viewModel.toggleGoalCompletion(goalId: goal.id)
            }) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(goal.isCompleted ? .green : .gray)
                    .font(.title3)
            }

            // Goal Info
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(goal.isCompleted)
                    .foregroundColor(goal.isCompleted ? .secondary : .primary)

                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct EmptyGoalsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))

            Text("Keine persönlichen Ziele")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    HabitCoachView(repository: LocalRepository())
}
