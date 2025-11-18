//
//  HaushaltsHeroApp.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

@main
struct HaushaltsHeroApp: App {

    // MARK: - Properties

    @StateObject private var appContainer = AppContainer()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appContainer)
        }
    }
}

/// Dependency injection container for the app
class AppContainer: ObservableObject {

    // MARK: - Properties

    /// The main repository instance (can be swapped for testing)
    let repository: AppRepository

    // MARK: - Initialization

    init(repository: AppRepository? = nil) {
        self.repository = repository ?? LocalRepository()
    }

    /// Create a test instance with mock data
    static func test(repository: AppRepository) -> AppContainer {
        return AppContainer(repository: repository)
    }
}

/// Placeholder ContentView - will be replaced with actual UI
struct ContentView: View {
    @EnvironmentObject var container: AppContainer

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Haushalts-Hero")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Frontend-only MVP")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()
                .padding()

            VStack(alignment: .leading, spacing: 12) {
                StatusRow(icon: "checkmark.circle.fill", text: "✅ Phase 0 abgeschlossen", color: .green)
                StatusRow(icon: "circle", text: "⏳ Challenge-Flow (Phase 1) in Arbeit", color: .orange)
                StatusRow(icon: "circle", text: "📋 Quests & Goals (Phase 2) geplant", color: .gray)
            }
            .padding()

            Spacer()

            Text("Lokale Datenhaltung • Keine Backend-Verbindung")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

struct StatusRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppContainer())
}
