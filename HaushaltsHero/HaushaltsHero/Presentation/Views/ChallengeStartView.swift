//
//  ChallengeStartView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for selecting a challenge category
struct ChallengeStartView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ChallengeViewModel
    @EnvironmentObject var container: AppContainer
    @State private var showPrivacyView = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Neue Challenge")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Wähle eine Kategorie")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    // Season Banner
                    SeasonBannerContainer(repository: container.repository)
                        .padding(.horizontal)

                    // Category Selection
                    VStack(spacing: 16) {
                    ForEach(ChallengeCategory.allCases, id: \.self) { category in
                        CategoryCard(category: category) {
                            viewModel.startChallenge(category: category)
                        }
                    }
                }
                .padding(.horizontal)

                // Info Text
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Mache ein Vorher- und Nachher-Foto für die beste Bewertung")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // Privacy Button
                Button(action: { showPrivacyView = true }) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.blue)
                        Text("Datenschutz & Privatsphäre")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPrivacyView) {
                PrivacyView()
            }
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: ChallengeCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: iconName)
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.description)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(categoryHint)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconName: String {
        switch category {
        case .mirror:
            return "mirror"
        case .toilet:
            return "drop.circle"
        case .room:
            return "bed.double"
        }
    }

    private var categoryHint: String {
        switch category {
        case .mirror:
            return "Putze einen Spiegel streifenfrei"
        case .toilet:
            return "Reinige eine Toilette gründlich"
        case .room:
            return "Räume ein Zimmer auf"
        }
    }
}

// MARK: - Preview

#Preview {
    ChallengeStartView(
        viewModel: ChallengeViewModel(repository: LocalRepository())
    )
}
