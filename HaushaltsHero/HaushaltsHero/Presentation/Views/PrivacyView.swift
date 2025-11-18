//
//  PrivacyView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View explaining privacy and data handling
struct PrivacyView: View {

    // MARK: - Properties

    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Datenschutz & Privatsphäre")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Deine Daten bleiben auf deinem Gerät")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                    Divider()

                    // Local Data Section
                    PrivacySection(
                        icon: "iphone",
                        iconColor: .blue,
                        title: "100% Lokal",
                        description: "Alle deine Challenges, Fotos und Fortschritte werden ausschließlich auf deinem iPhone gespeichert. Keine Cloud, kein Server, keine Datenübertragung."
                    )

                    // No Account Section
                    PrivacySection(
                        icon: "person.crop.circle.badge.xmark",
                        iconColor: .green,
                        title: "Kein Account erforderlich",
                        description: "Du benötigst keinen Account, keine E-Mail-Adresse und keine Registrierung. Die App funktioniert vollständig offline."
                    )

                    // Photo Processing Section
                    PrivacySection(
                        icon: "camera.fill",
                        iconColor: .orange,
                        title: "Fotos bleiben privat",
                        description: "Alle Foto-Analysen werden direkt auf deinem Gerät durchgeführt. Deine Bilder verlassen niemals dein iPhone."
                    )

                    // Future Features Section
                    PrivacySection(
                        icon: "arrow.up.forward.circle",
                        iconColor: .purple,
                        title: "Geplante Features",
                        description: "In zukünftigen Versionen werden optionale Cloud-Features verfügbar sein (z.B. Backup, Leaderboards). Diese sind vollständig optional und erfordern deine ausdrückliche Zustimmung."
                    )

                    Divider()

                    // Data Storage Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Was wird gespeichert?")
                            .font(.headline)

                        BulletPoint(text: "Challenge-Historie (Kategorie, Datum, Score)")
                        BulletPoint(text: "Vorher-/Nachher-Fotos (lokal im App-Verzeichnis)")
                        BulletPoint(text: "Wochenstatistiken und Fortschritte")
                        BulletPoint(text: "Deine persönlichen Ziele und Quests")
                        BulletPoint(text: "App-Einstellungen (Präferenzen)")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )

                    // Delete Data Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daten löschen")
                            .font(.headline)

                        Text("Da alle Daten lokal gespeichert werden, kannst du sie jederzeit vollständig entfernen, indem du die App deinstallierst. Es verbleiben keine Daten auf Servern oder in der Cloud.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )

                    // App Version Info
                    VStack(spacing: 8) {
                        Text("Frontend-only MVP • Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Keine Backend-Verbindung • Vollständig offline")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding()
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
}

// MARK: - Privacy Section Component

struct PrivacySection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Bullet Point Component

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.headline)
                .foregroundColor(.blue)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    PrivacyView()
}
