//
//  SettingsView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for app settings and future features
struct SettingsView: View {

    // MARK: - Properties

    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPrivacy = false

    // MARK: - Initialization

    init(repository: AppRepository) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(repository: repository))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                // Current Features Section
                Section {
                    Toggle("Haptic Feedback", isOn: $viewModel.enableHapticFeedback)
                    Toggle("Sound Effects", isOn: $viewModel.enableSoundEffects)
                    Toggle("Heatmap standardmäßig anzeigen", isOn: $viewModel.showHeatmapByDefault)
                } header: {
                    Text("Aktuelle Features")
                }

                // Future Features Section
                Section {
                    FutureFeatureRow(
                        icon: "icloud.fill",
                        title: "Cloud-Sync",
                        description: "Synchronisiere deine Daten über alle Geräte",
                        isEnabled: false
                    )

                    FutureFeatureRow(
                        icon: "list.number",
                        title: "Leaderboard",
                        description: "Vergleiche dich mit anderen Nutzern",
                        isEnabled: false
                    )

                    FutureFeatureRow(
                        icon: "crown.fill",
                        title: "Pro-Account",
                        description: "Erweiterte Analysen & Export-Funktionen",
                        isEnabled: false
                    )

                    FutureFeatureRow(
                        icon: "bell.fill",
                        title: "Push-Benachrichtigungen",
                        description: "Erinnerungen für tägliche Challenges",
                        isEnabled: false
                    )

                    FutureFeatureRow(
                        icon: "person.2.fill",
                        title: "Haushalts-Gruppen",
                        description: "Teile Fortschritte mit deinem Haushalt",
                        isEnabled: false
                    )
                } header: {
                    Text("Geplante Features")
                } footer: {
                    Text("Diese Features sind in Entwicklung und werden in zukünftigen Versionen verfügbar sein.")
                }

                // About Section
                Section {
                    Button(action: { showPrivacy = true }) {
                        HStack {
                            Label("Datenschutz", systemImage: "lock.shield")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Modus")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "iphone")
                                .font(.caption)
                            Text("Nur Lokal")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Info")
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyView()
            }
            .task {
                await viewModel.loadSettings()
            }
            .onChange(of: viewModel.enableHapticFeedback) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.enableSoundEffects) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.showHeatmapByDefault) { _ in
                Task { await viewModel.saveSettings() }
            }
        }
    }
}

// MARK: - Future Feature Row

struct FutureFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray.opacity(0.5))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .foregroundColor(isEnabled ? .primary : .secondary)

                    if !isEnabled {
                        Text("Coming Soon")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                }

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isEnabled {
                Toggle("", isOn: .constant(false))
                    .labelsHidden()
                    .disabled(true)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Settings ViewModel

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var enableHapticFeedback: Bool = true
    @Published var enableSoundEffects: Bool = true
    @Published var showHeatmapByDefault: Bool = false

    private let repository: AppRepository

    init(repository: AppRepository) {
        self.repository = repository
    }

    func loadSettings() async {
        do {
            let settings = try await repository.getUserSettings()
            enableHapticFeedback = settings.enableHapticFeedback
            enableSoundEffects = settings.enableSoundEffects
            showHeatmapByDefault = settings.showHeatmapByDefault
        } catch {
            print("Error loading settings: \(error)")
        }
    }

    func saveSettings() async {
        do {
            var settings = try await repository.getUserSettings()
            settings.enableHapticFeedback = enableHapticFeedback
            settings.enableSoundEffects = enableSoundEffects
            settings.showHeatmapByDefault = showHeatmapByDefault

            try await repository.saveUserSettings(settings)
        } catch {
            print("Error saving settings: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(repository: LocalRepository())
}
