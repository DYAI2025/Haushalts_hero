//
//  SeasonBannerView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for displaying an active season banner
struct SeasonBannerView: View {

    // MARK: - Properties

    let season: Season
    @State private var daysRemaining: Int = 0

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Season Header
            HStack {
                Image(systemName: seasonIcon)
                    .font(.title)
                    .foregroundColor(seasonColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(season.title)
                        .font(.headline)
                        .fontWeight(.bold)

                    if daysRemaining > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)

                            Text("Noch \(daysRemaining) \(daysRemaining == 1 ? "Tag" : "Tage")")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Theme Badge
                Text(season.theme.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(seasonColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(seasonColor.opacity(0.2))
                    )
            }

            // Description
            Text(season.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Progress Bar
            VStack(spacing: 6) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [seasonColor.opacity(0.7), seasonColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(seasonProgress), height: 6)
                            .animation(.spring(), value: seasonProgress)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text(formattedDate(season.startDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(formattedDate(season.endDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            seasonColor.opacity(0.1),
                            seasonColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: seasonColor.opacity(0.2), radius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(seasonColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            calculateDaysRemaining()
        }
    }

    // MARK: - Computed Properties

    private var seasonProgress: Double {
        let totalDuration = season.endDate.timeIntervalSince(season.startDate)
        let elapsed = Date().timeIntervalSince(season.startDate)
        let progress = elapsed / totalDuration
        return min(max(progress, 0.0), 1.0)
    }

    private var seasonColor: Color {
        switch season.theme.lowercased() {
        case "winter":
            return .cyan
        case "spring", "frühling":
            return .green
        case "summer", "sommer":
            return .orange
        case "autumn", "fall", "herbst":
            return .brown
        case "holiday", "feiertag":
            return .red
        default:
            return .blue
        }
    }

    private var seasonIcon: String {
        switch season.theme.lowercased() {
        case "winter":
            return "snowflake"
        case "spring", "frühling":
            return "leaf.fill"
        case "summer", "sommer":
            return "sun.max.fill"
        case "autumn", "fall", "herbst":
            return "leaf"
        case "holiday", "feiertag":
            return "gift.fill"
        default:
            return "sparkles"
        }
    }

    // MARK: - Methods

    private func calculateDaysRemaining() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: season.endDate)
        daysRemaining = max(0, components.day ?? 0)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

// MARK: - Season Banner Container

struct SeasonBannerContainer: View {
    @StateObject private var viewModel: SeasonViewModel

    init(repository: AppRepository) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if let season = viewModel.activeSeason {
                SeasonBannerView(season: season)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .task {
            await viewModel.loadActiveSeason()
        }
    }
}

// MARK: - Season ViewModel

@MainActor
class SeasonViewModel: ObservableObject {
    @Published var activeSeason: Season?

    private let repository: AppRepository

    init(repository: AppRepository) {
        self.repository = repository
    }

    func loadActiveSeason() async {
        do {
            activeSeason = try await repository.getActiveSeason()
        } catch {
            print("Error loading active season: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    let mockSeason = Season(
        title: "Winter-Putz 2025",
        description: "Mach dein Zuhause bereit für die kalte Jahreszeit! Extra Punkte für alle Challenges.",
        startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
        theme: "winter",
        bannerImageURL: nil
    )

    VStack {
        SeasonBannerView(season: mockSeason)
            .padding()

        Spacer()
    }
}
