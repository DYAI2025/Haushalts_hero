//
//  MicroLearningView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for browsing micro-learning cards
struct MicroLearningView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MicroLearningViewModel
    @State private var selectedCard: MicroLearningCard?
    @State private var searchText: String = ""
    @State private var selectedCategory: ChallengeCategory?

    // MARK: - Initialization

    init(repository: AppRepository) {
        _viewModel = StateObject(wrappedValue: MicroLearningViewModel(repository: repository))
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
                            // Category Filter
                            CategoryFilterView(selectedCategory: $selectedCategory)

                            // Cards Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(filteredCards) { card in
                                    MicroLearningCardTile(card: card) {
                                        selectedCard = card
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Wissen")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Suche...")
            .sheet(item: $selectedCard) { card in
                MicroLearningCardDetailView(card: card)
            }
            .task {
                await viewModel.loadCards()
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredCards: [MicroLearningCard] {
        var cards = viewModel.cards

        // Filter by category
        if let category = selectedCategory {
            cards = cards.filter { $0.category == category }
        }

        // Filter by search
        if !searchText.isEmpty {
            cards = cards.filter { card in
                card.title.localizedCaseInsensitiveContains(searchText) ||
                card.content.localizedCaseInsensitiveContains(searchText) ||
                card.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return cards
    }
}

// MARK: - Category Filter View

struct CategoryFilterView: View {
    @Binding var selectedCategory: ChallengeCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories
                CategoryFilterChip(
                    title: "Alle",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(ChallengeCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        title: category.description,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
    }
}

// MARK: - Micro Learning Card Tile

struct MicroLearningCardTile: View {
    let card: MicroLearningCard
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Category Icon
                HStack {
                    Image(systemName: categoryIcon)
                        .font(.title2)
                        .foregroundColor(categoryColor)

                    Spacer()

                    // Read Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(card.estimatedReadTime)s")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }

                // Title
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Tags
                if !card.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(card.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                )
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var categoryColor: Color {
        switch card.category {
        case .mirror: return .blue
        case .toilet: return .cyan
        case .room: return .indigo
        }
    }

    private var categoryIcon: String {
        switch card.category {
        case .mirror: return "mirror"
        case .toilet: return "drop.circle"
        case .room: return "bed.double"
        }
    }
}

// MARK: - Micro Learning Card Detail View

struct MicroLearningCardDetailView: View {
    let card: MicroLearningCard
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        // Category Badge
                        HStack {
                            Label(card.category.description, systemImage: categoryIcon)
                                .font(.subheadline)
                                .foregroundColor(categoryColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(categoryColor.opacity(0.2))
                                )

                            Spacer()

                            // Read Time
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text("\(card.estimatedReadTime) Sek.")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }

                        // Title
                        Text(card.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding()

                    Divider()

                    // Content
                    Text(card.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()

                    // Tags
                    if !card.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(card.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color.blue.opacity(0.1))
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var categoryColor: Color {
        switch card.category {
        case .mirror: return .blue
        case .toilet: return .cyan
        case .room: return .indigo
        }
    }

    private var categoryIcon: String {
        switch card.category {
        case .mirror: return "mirror"
        case .toilet: return "drop.circle"
        case .room: return "bed.double"
        }
    }
}

// MARK: - ViewModel

@MainActor
class MicroLearningViewModel: ObservableObject {
    @Published var cards: [MicroLearningCard] = []
    @Published var isLoading: Bool = false

    private let repository: AppRepository

    init(repository: AppRepository) {
        self.repository = repository
    }

    func loadCards() async {
        isLoading = true

        do {
            cards = try await repository.getMicroLearningCards(category: nil)
        } catch {
            print("Error loading micro learning cards: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    MicroLearningView(repository: LocalRepository())
}
