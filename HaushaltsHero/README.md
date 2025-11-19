# Haushalts-Hero iOS App

**Version:** MVP Phase 0
**Platform:** iOS 16.0+
**Framework:** SwiftUI
**Architecture:** MVVM + Repository Pattern

---

## 📁 Projektstruktur

```
HaushaltsHero/
├── HaushaltsHero/
│   ├── App/
│   │   └── HaushaltsHeroApp.swift          # App Entry Point & DI Container
│   ├── Domain/
│   │   ├── Models/                          # Business Logic Models
│   │   │   ├── Challenge.swift
│   │   │   ├── ExplainableScore.swift
│   │   │   ├── Quest.swift
│   │   │   ├── WeeklyStats.swift
│   │   │   ├── CoachTip.swift
│   │   │   └── UserSettings.swift
│   │   └── Services/                        # Business Logic Services (TBD)
│   ├── Data/
│   │   ├── Repositories/
│   │   │   ├── AppRepository.swift          # Repository Protocol
│   │   │   └── LocalRepository.swift        # Local Implementation
│   │   └── LocalStorage/                    # Storage Utilities (TBD)
│   ├── Presentation/
│   │   ├── Views/                           # SwiftUI Views (TBD)
│   │   └── ViewModels/                      # ViewModels (TBD)
│   └── Resources/                           # Assets, JSON, etc. (TBD)
└── HaushaltsHeroTests/                      # Unit Tests (TBD)
```

---

## ✅ Phase 0: Abgeschlossen

### T0.1-FE: Frontend-Scope dokumentiert
- ✅ Dokumentation in `docs/frontend_scope.md`
- ✅ MVP-Definitionen (FE-1/2/3) definiert
- ✅ Architektur-Diagramme (Mermaid) erstellt
- ✅ Requirements & Success Criteria dokumentiert

### T0.2-FE: Data-Abstraktion & Local Repository
- ✅ **Domain Models** erstellt:
  - `Challenge`: Challenge-Datenmodell mit Kategorie, Fotos, Score
  - `ExplainableScore`: Score mit Subscores, Confidence, Heatmap
  - `Quest` & `Goal`: Gamification-Modelle
  - `WeeklyStats`: Wochenstatistiken
  - `CoachTip` & `MicroLearningCard`: Content-Modelle
  - `Season`: Season-System
  - `UserSettings`: Nutzer-Einstellungen

- ✅ **AppRepository Protocol** definiert:
  - Challenge-Operationen (CRUD)
  - Quests & Goals Management
  - Statistiken (Wochen- & Monatsansicht)
  - Content (Coaching, Micro-Learning, Seasons)
  - Settings & Photo Management

- ✅ **LocalRepository Implementation**:
  - Vollständige lokale Implementierung mit UserDefaults
  - File-basiertes Photo Storage
  - Dummy-Daten für Quests, Goals, Coaching-Tipps, etc.
  - Wöchentliche Reset-Logik für Quests/Goals

- ✅ **App Structure**:
  - `HaushaltsHeroApp.swift`: App Entry Point
  - `AppContainer`: Dependency Injection Container
  - Placeholder `ContentView` für Testing

---

## 🎯 Nächste Schritte (Phase 1)

### T1.1-FE: Challenge-Flow-UI
- [ ] `ChallengeStartView.swift` - Kategorie-Auswahl
- [ ] `CameraFlowView.swift` - Foto-Aufnahme (Vorher/Nachher)
- [ ] `ScoreResultView.swift` - Ergebnis-Anzeige
- [ ] `ChallengeViewModel.swift` - ViewModel für Challenge-Flow

### T1.2-FE: Explainable Score
- [ ] Score-Berechnung mit Subscores
- [ ] Template-basierte Erklärtext-Generierung
- [ ] UI für Subscore-Anzeige

### T1.3-FE: Heatmap-Overlay
- [ ] `HeatmapOverlayView.swift`
- [ ] Einfacher Heatmap-Generator (Pixel-Differenz)

### T1.4-FE: Confidence & Re-Try Flow
- [ ] `ConfidenceEvaluator.swift`
- [ ] UI-Elemente für Re-Try-Option

### T1.5-FE: Privacy-Screen
- [ ] `PrivacyView.swift` - Erklärt lokale Verarbeitung

---

## 🛠 Setup (für Xcode)

**Hinweis:** Diese Dateien sind für die Integration in ein Xcode-Projekt vorbereitet.

### Schritte:
1. Öffne Xcode und erstelle ein neues iOS-Projekt:
   - **Template:** App
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Bundle Identifier:** `com.haushalts-hero.app`
   - **Minimum Deployment:** iOS 16.0

2. Kopiere alle Swift-Dateien aus diesem Verzeichnis in dein Xcode-Projekt

3. Stelle sicher, dass die Ordnerstruktur beibehalten wird:
   - `App/` → App-Gruppe in Xcode
   - `Domain/Models/` → Domain/Models-Gruppe
   - `Data/Repositories/` → Data/Repositories-Gruppe

4. Baue das Projekt (`Cmd+B`)

---

## 🧪 Testing

Die App kann aktuell gebaut werden und zeigt einen Placeholder-Screen.

**Nächste Test-Schritte:**
- Unit-Tests für `LocalRepository` (Phase 5)
- UI-Tests für Challenge-Flow (Phase 5)
- Usability-Tests (Phase 5)

---

## 📋 Architecture Notes

### Repository Pattern
Die App verwendet das **Repository Pattern** für Daten-Abstraktion:
- **Protocol:** `AppRepository` definiert alle Daten-Operationen
- **Implementation:** `LocalRepository` nutzt UserDefaults + FileManager
- **Future:** `RemoteRepository` kann später hinzugefügt werden (Backend-Integration)

### MVVM Pattern
- **Models:** Domain-Layer (`Challenge`, `Score`, etc.)
- **Views:** SwiftUI Views (Presentation-Layer)
- **ViewModels:** Business-Logic-Adapter zwischen View und Repository

### Dependency Injection
- `AppContainer` verwaltet Dependencies (Repository, Services, etc.)
- Wird als `@EnvironmentObject` in SwiftUI-Views injiziert
- Ermöglicht einfaches Testing mit Mock-Daten

---

## 🚀 MVP-Timeline

| Phase | Status | Beschreibung |
|-------|--------|--------------|
| **Phase 0** | ✅ Abgeschlossen | Architektur & Setup |
| **Phase 1** | ⏳ In Arbeit | MVP FE-1: Explainable Score Demo |
| **Phase 2** | 📋 Geplant | MVP FE-2: Local Hero (Gamification) |
| **Phase 3** | 📋 Geplant | Coaching & Micro-Learning |
| **Phase 4** | 📋 Geplant | Pro Preview & Architektur-Härtung |
| **Phase 5** | 📋 Geplant | Testing & Usability |

---

## 📄 Lizenz

Internes Projekt - Alle Rechte vorbehalten.

---

**Erstellt von:** AI Agent
**Datum:** 2025-11-18
**Nächste Review:** Nach T1.1-FE (Challenge-Flow-UI)
