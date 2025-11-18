//
//  HomeView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// Main home view with tab navigation
struct HomeView: View {

    // MARK: - Properties

    @EnvironmentObject var container: AppContainer
    @State private var selectedTab: Tab = .challenge

    // MARK: - Tab Enum

    enum Tab {
        case challenge
        case quests
        case coach
        case learning
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Challenge Tab
            MainView()
                .tabItem {
                    Label("Challenge", systemImage: "sparkles")
                }
                .tag(Tab.challenge)

            // Quests Tab
            QuestsView(repository: container.repository)
                .tabItem {
                    Label("Quests", systemImage: "star.fill")
                }
                .tag(Tab.quests)

            // Habit Coach Tab
            HabitCoachView(repository: container.repository)
                .tabItem {
                    Label("Coach", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.coach)

            // Micro Learning Tab
            MicroLearningView(repository: container.repository)
                .tabItem {
                    Label("Wissen", systemImage: "book.fill")
                }
                .tag(Tab.learning)
        }
        .accentColor(.blue)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppContainer())
}
