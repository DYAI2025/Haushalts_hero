//
//  QuestsView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for displaying quests and goals
struct QuestsView: View {

    // MARK: - Properties

    @StateObject private var viewModel: QuestsViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Initialization

    init(repository: AppRepository) {
        _viewModel = StateObject(wrappedValue: QuestsViewModel(repository: repository))
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
                            // Header Stats
                            if let stats = viewModel.weeklyStats {
                                WeeklyStatsCard(stats: stats)
                            }

                            // Goal Progress
                            if let goal = viewModel.activeGoal {
                                GoalProgressCard(goal: goal)
                            }

                            // Quests Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Deine Quests")
                                        .font(.title2)
                                        .fontWeight(.bold)

                                    Spacer()

                                    if viewModel.hasCompletedQuests {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("\(viewModel.completedQuestsCount)/\(viewModel.totalQuestsCount)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal)

                                if viewModel.activeQuests.isEmpty {
                                    EmptyQuestsView()
                                } else {
                                    ForEach(viewModel.activeQuests) { quest in
                                        QuestCard(quest: quest, viewModel: viewModel)
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Rewards Summary
                            if !viewModel.activeQuests.isEmpty {
                                RewardsSummaryCard(viewModel: viewModel)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Quests & Ziele")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refresh()
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

// MARK: - Weekly Stats Card

struct WeeklyStatsCard: View {
    let stats: WeeklyStats

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("Diese Woche")
                    .font(.headline)

                Spacer()
            }

            HStack(spacing: 20) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(stats.challengesCompleted)",
                    label: "Challenges",
                    color: .green
                )

                Divider()
                    .frame(height: 40)

                StatItem(
                    icon: "star.fill",
                    value: String(format: "%.0f", stats.averageScore),
                    label: "Ø Score",
                    color: .orange
                )

                Divider()
                    .frame(height: 40)

                StatItem(
                    icon: "trophy.fill",
                    value: "\(stats.totalPoints)",
                    label: "Punkte",
                    color: .purple
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

struct StatItem: View {
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

// MARK: - Goal Progress Card

struct GoalProgressCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)

                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if goal.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }

            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("\(goal.currentPoints) / \(goal.targetPoints) Punkte")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(goal.progressPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.2))
                            .frame(height: 12)

                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(goal.progressPercentage) / 100,
                                height: 12
                            )
                            .animation(.spring(), value: goal.progressPercentage)
                    }
                }
                .frame(height: 12)
            }

            // Remaining
            if !goal.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)

                    Text("Noch \(goal.targetPoints - goal.currentPoints) Punkte bis zum Ziel!")
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

// MARK: - Quest Card

struct QuestCard: View {
    let quest: Quest
    let viewModel: QuestsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Category Icon
                if let category = quest.category {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: categoryIcon)
                            .foregroundColor(categoryColor)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.headline)

                    Text(quest.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }

            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(viewModel.progressText(for: quest))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)

                        Text("+\(quest.rewardPoints)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(quest.isCompleted ? Color.green : categoryColor)
                            .frame(
                                width: geometry.size.width * CGFloat(quest.progressPercentage) / 100,
                                height: 8
                            )
                            .animation(.spring(), value: quest.progressPercentage)
                    }
                }
                .frame(height: 8)
            }

            // Status Text
            if !quest.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .foregroundColor(categoryColor)
                        .font(.caption)

                    let remaining = viewModel.remainingCount(for: quest)
                    Text("Noch \(remaining) \(remaining == 1 ? "mal" : "mal")")
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
    }

    private var categoryColor: Color {
        guard let category = quest.category else { return .blue }

        switch category {
        case .mirror: return .blue
        case .toilet: return .cyan
        case .room: return .indigo
        }
    }

    private var categoryIcon: String {
        guard let category = quest.category else { return "star" }

        switch category {
        case .mirror: return "mirror"
        case .toilet: return "drop.circle"
        case .room: return "bed.double"
        }
    }
}

// MARK: - Empty Quests View

struct EmptyQuestsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("Keine aktiven Quests")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Quests werden wöchentlich zurückgesetzt")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Rewards Summary Card

struct RewardsSummaryCard: View {
    let viewModel: QuestsViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Belohnungen")
                    .font(.headline)

                Text("\(viewModel.earnedRewardPoints) / \(viewModel.totalPossibleRewardPoints) Punkte verdient")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 60, height: 60)

                VStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)

                    Text("\(viewModel.earnedRewardPoints)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
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

// MARK: - Preview

#Preview {
    QuestsView(repository: LocalRepository())
}
