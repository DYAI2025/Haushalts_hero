//
//  CoachingCardView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for displaying a coaching tip card
struct CoachingCardView: View {

    // MARK: - Properties

    let tip: CoachTip
    @State private var isExpanded: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                // Title
                Text(tip.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Priority Badge
                if tip.priority >= 8 {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            // Content
            Text(tip.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut, value: isExpanded)

            // Expand Button
            if tip.content.count > 100 {
                Button(action: { isExpanded.toggle() }) {
                    Text(isExpanded ? "Weniger anzeigen" : "Mehr lesen")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }

            // Category Tag
            if let category = tip.category {
                HStack(spacing: 4) {
                    Image(systemName: categoryIcon(for: category))
                        .font(.caption2)
                    Text(category.description)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.05), Color.cyan.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helper Methods

    private func categoryIcon(for category: ChallengeCategory) -> String {
        switch category {
        case .mirror: return "mirror"
        case .toilet: return "drop.circle"
        case .room: return "bed.double"
        }
    }
}

// MARK: - Coaching Section for ScoreResultView

struct CoachingSectionView: View {

    // MARK: - Properties

    let score: ExplainableScore
    let repository: AppRepository
    @State private var coachingTips: [CoachTip] = []
    @State private var improvementAreas: [ImprovementArea] = []
    @State private var isLoading: Bool = true

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "person.fill.checkmark")
                    .foregroundColor(.blue)
                Text("Dein Coach")
                    .font(.headline)
            }
            .padding(.horizontal)

            if isLoading {
                ProgressView()
                    .padding()
            } else {
                // Improvement Areas
                if !improvementAreas.isEmpty {
                    ImprovementAreasView(areas: improvementAreas)
                        .padding(.horizontal)
                }

                // Coaching Tips
                if !coachingTips.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(coachingTips) { tip in
                            CoachingCardView(tip: tip)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    EmptyCoachingView()
                        .padding(.horizontal)
                }
            }
        }
        .task {
            await loadCoachingData()
        }
    }

    // MARK: - Methods

    private func loadCoachingData() async {
        isLoading = true

        do {
            // Load all coaching tips
            let allTips = try await repository.getAllCoachingTips()

            // Use coaching engine to filter relevant tips
            let coachingEngine = CoachingEngine()
            coachingTips = coachingEngine.getRelevantTips(
                for: score,
                from: allTips,
                maxTips: 3
            )

            // Get improvement areas
            improvementAreas = coachingEngine.getImprovementAreas(for: score)

        } catch {
            print("Error loading coaching data: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Improvement Areas View

struct ImprovementAreasView: View {
    let areas: [ImprovementArea]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verbesserungspotenzial")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            ForEach(areas, id: \.name) { area in
                ImprovementAreaRow(area: area)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct ImprovementAreaRow: View {
    let area: ImprovementArea

    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(area.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(area.currentValue) → \(area.targetValue) Punkte")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(area.priority.rawValue)
                .font(.caption)
                .foregroundColor(priorityColor)
        }
    }

    private var priorityColor: Color {
        switch area.priority {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }
}

// MARK: - Empty Coaching View

struct EmptyCoachingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("Perfekt gemacht!")
                .font(.headline)

            Text("Keine spezifischen Verbesserungsvorschläge. Weiter so!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview {
    let mockTip = CoachTip(
        title: "Streifenfrei putzen",
        content: "Verwende Mikrofasertücher und arbeite in kreisenden Bewegungen. Für beste Ergebnisse: erst mit feuchtem Tuch reinigen, dann mit trockenem Tuch nachpolieren.",
        triggerRules: [],
        category: .mirror,
        priority: 10
    )

    VStack {
        CoachingCardView(tip: mockTip)
            .padding()

        Spacer()
    }
}
