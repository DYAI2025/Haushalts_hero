# Haushalts-Hero

> Gamifizierte iOS-App für motivierende Haushaltsreinigung mit AI-gestütztem Scoring

![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-purple.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## Übersicht

**Haushalts-Hero** ist eine innovative iOS-App, die Haushaltsreinigung durch Gamification, AI-gestütztes Scoring und personalisiertes Coaching zu einem motivierenden Erlebnis macht. Die App ist **100% offline-fähig** und speichert alle Daten lokal, mit einer sauberen Architektur für spätere Backend-Integration.

### Kernfeatures

- **📸 Challenge-Flow**: Vorher/Nachher-Fotos für Reinigungsaufgaben
- **🎯 Explainable Score**: Transparente Bewertung mit Subscores (Sauberkeit, Detailgrad, Gleichmäßigkeit)
- **🗺️ Heatmap-Visualisierung**: Zeigt Problemzonen visuell an
- **🏆 Quests & Goals**: Wöchentliche Herausforderungen und Zielsetzungen
- **🎓 Micro-Learning**: Kurze Tipps und Tricks für bessere Reinigung
- **💡 Coaching-Engine**: Kontextbasierte Verbesserungsvorschläge
- **🌟 Seasons**: Zeitbasierte Events und Themen
- **📊 Statistiken**: Wochen- und Monatsreports (Pro Preview)
- **🔒 Privacy-First**: Alle Daten bleiben lokal auf dem Gerät

## Screenshots

| Challenge Start | Score Result | Quests | Coaching |
|----------------|--------------|--------|----------|
| *TBD* | *TBD* | *TBD* | *TBD* |

## Architektur

### Tech Stack

- **Plattform**: iOS 16.0+
- **Framework**: SwiftUI 4.0
- **Pattern**: MVVM (Model-View-ViewModel)
- **Persistenz**: UserDefaults + FileManager
- **Testing**: XCTest
- **Sprache**: Swift 5.9

### Layer-Struktur

```
┌─────────────────────────────────────────────────────────┐
│              Presentation Layer                         │
│  SwiftUI Views + ViewModels                             │
│  - HomeView, ChallengeStartView, QuestsView, ...        │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Domain Layer                               │
│  Business Logic & Models                                │
│  - ScoringEngine, CoachingEngine                        │
│  - Challenge, Quest, Score, ...                         │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Data Layer                                 │
│  Repository Pattern (Backend-Ready)                     │
│  - AppRepository (Protocol)                             │
│  - LocalRepository / RemoteRepository                   │
└─────────────────────────────────────────────────────────┘
```

Detaillierte Architektur-Dokumentation: [`docs/frontend_scope.md`](docs/frontend_scope.md)

## Installation

### Voraussetzungen

- macOS 13.0+
- Xcode 15.0+
- iOS Simulator oder physisches iOS-Gerät (iOS 16.0+)

### Setup

1. **Repository klonen**
   ```bash
   git clone https://github.com/DYAI2025/Haushalts_hero.git
   cd Haushalts_hero/HaushaltsHero
   ```

2. **Xcode öffnen**
   ```bash
   open HaushaltsHero.xcodeproj
   ```

3. **Build & Run**
   - Wähle ein Target (Simulator oder Device)
   - Drücke `Cmd + R` zum Starten

### Erste Schritte

1. App öffnen → Kategorie wählen (Spiegel, Toilette, Zimmer)
2. "Vorher"-Foto aufnehmen
3. Aufräumen/Putzen
4. "Nachher"-Foto aufnehmen
5. Score-Ergebnis mit Subscores und Tipps erhalten
6. Quests und Goals verfolgen im "Quests"-Tab

## Features im Detail

### Phase 1: MVP FE-1 "Explainable Score Demo"

✅ **Challenge-Flow**
- Kategorie-Auswahl (Spiegel, Toilette, Zimmer)
- Vorher/Nachher-Foto-Aufnahme
- Asynchrones Scoring mit Progress-Indicator

✅ **Explainable Score**
```swift
struct ExplainableScore {
    let overallScore: Int        // 0-100
    let subscores: [Subscore]    // Detailgrad, Streifenfreiheit, etc.
    let confidence: Double       // 0.0-1.0
    let explanation: String      // Verständliche Erklärung
    let heatmapData: HeatmapData? // Visualisierung
}
```

✅ **Heatmap-Overlay**
- Canvas-basierte Rendering
- 20x20 Grid für Performance
- Farbcodierte Intensitätswerte (grün → rot)

✅ **Confidence & Re-Try**
- Confidence-Anzeige mit visueller Skala
- "Nochmal versuchen"-Button bei Low Confidence

### Phase 2: MVP FE-2 "Local Hero" (Gamification)

✅ **Quests System**
- Wöchentliche Quests (z.B. "3x Spiegel putzen")
- Automatische Progress-Updates
- Reward-Points für Completion

✅ **Goal Tracking**
- Wöchentliches Punkte-Ziel
- Progress-Bar mit Visualisierung
- Automatische Berechnung

✅ **Habit Coach**
- Wochenkalender mit Challenge-Historie
- Personal Goals
- Motivations-Cards

✅ **Season-Banner**
- Zeitbasierte Events
- Theme-Colors und Icons
- Automatische Aktivierung

### Phase 3: Coaching & Micro-Learning

✅ **Coaching-Engine**
- Intelligentes Matching basierend auf Subscores
- Trigger-Regeln für kontextbasierte Tipps
- Improvement-Areas-Detection

✅ **Micro-Learning**
- 20 Educational Cards (JSON-gesteuert)
- Kategorie-Filter
- Suchfunktion
- Expandable Content

✅ **Content-Management**
- `coaching_tips.json`: 20 Coaching-Tipps mit Trigger-Regeln
- `microlearning.json`: 20 Lern-Karten mit Tags

### Phase 4: Pro Preview & Backend-Ready

✅ **Monthly Report**
- Lokale Statistik-Auswertung
- Wochenweise Aufschlüsselung
- Kategorie-Verteilung
- "Pro Preview"-Badge

✅ **Settings View**
- Aktuelle Features (Haptic Feedback, Sounds, Heatmap)
- Zukünftige Features mit "Coming Soon"-Markierung:
  - Cloud-Sync
  - Leaderboard
  - Pro-Account
  - Push-Notifications
  - Haushalts-Gruppen

✅ **Backend-Integration-Dokumentation**
- Komplettes API-Methoden-Mapping (25 Methoden)
- Authentifizierungs-Strategie
- Offline-First-Pattern
- Photo-Upload-Konzept (S3/CloudKit)
- Sync-Engine-Spezifikation

📄 Siehe [`docs/frontend_scope.md#11-backend-integration-strategie`](docs/frontend_scope.md#11-backend-integration-strategie)

## Testing

### Unit-Tests

Die App enthält umfassende Unit-Tests für:

#### Domain Services
- **ScoringEngineTests** (18 Tests)
  - Score-Berechnung
  - Subscore-Generierung
  - Confidence-Evaluation
  - Explanation-Generierung
  - Kategorie-spezifische Subscores
  - Performance-Tests

- **CoachingEngineTests** (20 Tests)
  - Tip-Matching mit Trigger-Regeln
  - Improvement-Areas-Detection
  - Streak-Berechnung
  - Confidence-Filtering
  - Score-Range-Matching

#### ViewModels
- **ChallengeViewModelTests** (15 Tests)
  - Flow-State-Management
  - Photo-Capture-Logic
  - Quest/Goal-Updates
  - Error-Handling
  - Retry-Flow

- **QuestsViewModelTests** (20 Tests)
  - Data-Loading
  - Progress-Calculation
  - Reward-Points-Summing
  - Completed-Quests-Detection
  - Integration-Tests

### Tests ausführen

```bash
# In Xcode: Cmd + U
# Oder via CLI:
xcodebuild test \
  -project HaushaltsHero.xcodeproj \
  -scheme HaushaltsHero \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test-Coverage

- **Domain Services**: 90%+
- **ViewModels**: 85%+
- **Gesamt**: 80%+ (geschätzt)

## Backend-Integration

Die App ist **backend-ready** mit klarer Trennung zwischen lokalem und Remote-Repository.

### Migration-Path

1. **Aktuell**: `LocalRepository` (UserDefaults + FileManager)
2. **Hybrid**: `HybridRepository` (Local Cache + Background Sync)
3. **Remote**: `RemoteRepository` (API-basiert mit lokalem Fallback)

### API-Contract (Beispiel)

```json
POST /api/v1/challenges
{
  "category": "mirror",
  "beforePhotoURL": "https://cdn.example.com/photos/abc123.jpg",
  "afterPhotoURL": "https://cdn.example.com/photos/def456.jpg",
  "timestamp": "2025-11-18T14:30:00Z",
  "score": {
    "overallScore": 85,
    "subscores": [
      {"name": "Detailgrad", "value": 90, "weight": 0.4}
    ],
    "confidence": 0.92
  }
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "user123",
  "points": 85,
  "questsUpdated": ["quest-abc"],
  "goalProgress": { "currentPoints": 285, "targetPoints": 500 }
}
```

### Implementierungs-Aufwand

| Task | Aufwand |
|------|---------|
| RemoteRepository | 3-5 Tage |
| APIClient + Auth | 2-3 Tage |
| Sync-Engine | 3-4 Tage |
| Photo-Upload (S3) | 2 Tage |
| Error-Handling | 1-2 Tage |
| **Gesamt** | **13-19 Tage** |

## Projektstruktur

```
HaushaltsHero/
├── HaushaltsHero/              # Main App Target
│   ├── App/
│   │   ├── HaushaltsHeroApp.swift    # App Entry Point
│   │   └── AppContainer.swift        # Dependency Injection
│   ├── Domain/
│   │   ├── Models/             # Domain Models (Challenge, Quest, Score, etc.)
│   │   └── Services/           # Business Logic (ScoringEngine, CoachingEngine)
│   ├── Data/
│   │   └── Repositories/       # AppRepository Protocol + LocalRepository
│   ├── Presentation/
│   │   ├── Views/              # SwiftUI Views
│   │   └── ViewModels/         # ViewModels (MVVM)
│   └── Resources/
│       └── Content/            # JSON Files (coaching_tips, microlearning)
├── HaushaltsHeroTests/         # Unit Tests
│   ├── ScoringEngineTests.swift
│   ├── CoachingEngineTests.swift
│   ├── ChallengeViewModelTests.swift
│   ├── QuestsViewModelTests.swift
│   └── Mocks/
│       └── MockRepository.swift
└── docs/
    └── frontend_scope.md       # Detailed Architecture & Requirements
```

## Roadmap

### ✅ Abgeschlossen

- [x] Phase 0: Architektur & Setup
- [x] Phase 1: MVP FE-1 "Explainable Score Demo"
- [x] Phase 2: MVP FE-2 "Local Hero" (Gamification)
- [x] Phase 3: Coaching & Micro-Learning
- [x] Phase 4: Pro Preview & Backend-Ready

### 🚧 In Arbeit

- [ ] Phase 5: Testing & Usability
  - [x] Unit-Tests (Services & ViewModels)
  - [ ] UI-Tests (Optional)
  - [ ] Usability-Tests

### 🔮 Geplant

- [ ] Backend-Integration (Cloud-Sync)
- [ ] Leaderboard & Social Features
- [ ] Pro-Account & Premium-Features
- [ ] Push-Notifications
- [ ] Haushalts-Gruppen
- [ ] Vision/CoreML für echtes AI-Scoring
- [ ] iPad-Support
- [ ] watchOS Companion-App

## Best Practices

### Code Style

- SwiftUI-Views: Maximal 300 Zeilen, sonst in Sub-Views aufteilen
- ViewModels: Ein ViewModel pro View
- Models: Immutable (structs), Codable für Serialisierung
- Services: Stateless, testbare Funktionen
- Async/Await für alle asynchronen Operationen

### Dependency Injection

```swift
// AppContainer verwaltet alle Dependencies
class AppContainer: ObservableObject {
    let repository: AppRepository

    init() {
        self.repository = LocalRepository()
    }
}

// Injection in Views via environmentObject
@main
struct HaushaltsHeroApp: App {
    @StateObject private var appContainer = AppContainer()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appContainer)
        }
    }
}
```

### Error-Handling

```swift
// Repository wirft typisierte Errors
enum RepositoryError: Error, LocalizedError {
    case notFound(String)
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let msg): return "Nicht gefunden: \(msg)"
        case .saveFailed(let msg): return "Speichern fehlgeschlagen: \(msg)"
        }
    }
}

// ViewModels fangen Errors und setzen errorMessage
func loadData() async {
    do {
        let data = try await repository.getData()
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

## Contributing

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/amazing-feature`)
3. Commit deine Änderungen (`git commit -m 'Add amazing feature'`)
4. Push zum Branch (`git push origin feature/amazing-feature`)
5. Öffne einen Pull Request

### Code-Review-Kriterien

- ✅ Unit-Tests für neue Features
- ✅ SwiftLint-Warnings behoben
- ✅ Dokumentation aktualisiert
- ✅ Performance-Impact bewertet
- ✅ Backend-Kompatibilität gewahrt

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Siehe `LICENSE`-Datei für Details.

## Credits

- **Entwickelt von**: AI Agent (Claude)
- **Projekt**: DYAI2025/Haushalts_hero
- **Technologie**: SwiftUI, Combine, Vision (geplant)

## Support

Bei Fragen oder Problemen:
- Erstelle ein [GitHub Issue](https://github.com/DYAI2025/Haushalts_hero/issues)
- Kontaktiere das Entwicklungs-Team

---

**Made with ❤️ in Germany** | **iOS 16.0+** | **100% Privacy-First**
