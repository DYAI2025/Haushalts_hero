//
//  MonthlyReportView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for displaying monthly report (Pro Preview)
struct MonthlyReportView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MonthlyReportViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Initialization

    init(repository: AppRepository) {
        _viewModel = StateObject(wrappedValue: MonthlyReportViewModel(repository: repository))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Erstelle Bericht...")
                } else if let report = viewModel.monthlyReport {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Pro Preview Badge
                            ProPreviewBadge()

                            // Header
                            MonthHeaderView(report: report)

                            // Main Stats
                            MainStatsView(report: report)

                            // Weekly Breakdown
                            WeeklyBreakdownView(report: report)

                            // Insights
                            InsightsView(report: report)

                            // Upgrade CTA
                            UpgradeCallToAction()
                        }
                        .padding()
                    }
                } else {
                    EmptyReportView()
                }
            }
            .navigationTitle("Monatsreport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadCurrentMonthReport()
            }
        }
    }
}

// MARK: - Pro Preview Badge

struct ProPreviewBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)

            Text("Pro Preview")
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Text("Lokal")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

// MARK: - Month Header

struct MonthHeaderView: View {
    let report: MonthlyReport

    var body: some View {
        VStack(spacing: 8) {
            Text(report.monthName)
                .font(.title)
                .fontWeight(.bold)

            if report.isRecordMonth {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Rekord-Monat!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - Main Stats View

struct MainStatsView: View {
    let report: MonthlyReport

    var body: some View {
        VStack(spacing: 16) {
            // Top Row
            HStack(spacing: 16) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(report.totalChallenges)",
                    label: "Challenges",
                    color: .green
                )

                StatCard(
                    icon: "star.fill",
                    value: String(format: "%.0f", report.averageScore),
                    label: "Ø Score",
                    color: .orange
                )
            }

            // Bottom Row
            HStack(spacing: 16) {
                StatCard(
                    icon: "trophy.fill",
                    value: "\(report.totalPoints)",
                    label: "Punkte",
                    color: .purple
                )

                if let category = report.topCategory {
                    StatCard(
                        icon: categoryIcon(for: category),
                        value: category.description,
                        label: "Top",
                        color: .blue
                    )
                } else {
                    StatCard(
                        icon: "questionmark",
                        value: "-",
                        label: "Top",
                        color: .gray
                    )
                }
            }
        }
    }

    private func categoryIcon(for category: ChallengeCategory) -> String {
        switch category {
        case .mirror: return "mirror"
        case .toilet: return "drop.circle"
        case .room: return "bed.double"
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8)
        )
    }
}

// MARK: - Weekly Breakdown View

struct WeeklyBreakdownView: View {
    let report: MonthlyReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wochen-Übersicht")
                .font(.headline)

            if report.weeklyBreakdown.isEmpty {
                Text("Noch keine Daten für diesen Monat")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(report.weeklyBreakdown) { week in
                    WeekRow(week: week)
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
}

struct WeekRow: View {
    let week: WeeklyBreakdown

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(week.weekNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(week.challengesCompleted) Challenges")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Ø \(String(format: "%.0f", week.averageScore))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Score")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(week.totalPoints)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Punkte")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Insights View

struct InsightsView: View {
    let report: MonthlyReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Erkenntnisse")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                if report.totalChallenges == 0 {
                    InsightRow(text: "Starte deine erste Challenge in diesem Monat!")
                } else {
                    if report.averageScore >= 80 {
                        InsightRow(text: "Hervorragender Durchschnitt! Du bist ein Profi! 🌟")
                    } else if report.averageScore >= 70 {
                        InsightRow(text: "Guter Durchschnitt! Mit etwas mehr Sorgfalt kommst du über 80.")
                    } else {
                        InsightRow(text: "Konzentriere dich auf Qualität statt Quantität für bessere Scores.")
                    }

                    if report.totalChallenges >= 20 {
                        InsightRow(text: "Fantastische Aktivität! Du hast \(report.totalChallenges) Challenges geschafft!")
                    }

                    if let category = report.topCategory {
                        InsightRow(text: "Deine Stärke: \(category.description). Probiere auch die anderen Kategorien!")
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }
}

struct InsightRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.yellow)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Upgrade CTA

struct UpgradeCallToAction: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pro-Version (Coming Soon)")
                        .font(.headline)

                    Text("Zukünftige Features:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                FeatureRow(text: "Cloud-Sync über Geräte hinweg")
                FeatureRow(text: "Vergleich mit Vormonaten")
                FeatureRow(text: "Erweiterte Analysen & Trends")
                FeatureRow(text: "Export als PDF")
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
                .font(.caption)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Empty Report View

struct EmptyReportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("Noch keine Daten")
                .font(.headline)

            Text("Starte Challenges, um deinen Monatsreport zu sehen!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    MonthlyReportView(repository: LocalRepository())
}
