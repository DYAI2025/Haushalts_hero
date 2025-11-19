# Haushalts-Hero – Multimedia Enhancement Plan

**Version:** 1.0
**Datum:** 2025-11-19
**Status:** Phase 6 – Multimedia & Polish

---

## 1. Übersicht

Dieser Plan beschreibt die Integration von **Grafiken, Musik, Animationen und Videos** in den Haushalts-Hero, um die User Experience auf ein Premium-Level zu heben.

### Ziele

1. **Visuelles Upgrade**: Animationen, Illustrationen und Hero-Character
2. **Audio-Experience**: Sound-Effekte, Hintergrundmusik, Haptic-Patterns
3. **Video-Content**: Tutorials, Time-Lapse, Motivation-Clips
4. **Performance**: Alle Assets optimiert, keine Verzögerung der App-Performance
5. **Toggle-Optionen**: Nutzer können Audio/Video deaktivieren

---

## 2. Phasen-Übersicht

| Phase | Beschreibung | Aufwand | Priorität |
|-------|--------------|---------|-----------|
| **Phase 6.1** | Audio-System & Sound-Effekte | 2-3 Tage | HIGH |
| **Phase 6.2** | Lottie-Animationen & Hero-Character | 3-4 Tage | HIGH |
| **Phase 6.3** | Video-Tutorials & Micro-Learning | 3-5 Tage | MEDIUM |
| **Phase 6.4** | Advanced Features (Time-Lapse, AR) | 5-7 Tage | LOW |
| **Phase 6.5** | Asset-Optimierung & Performance | 1-2 Tage | HIGH |

**Gesamt-Aufwand:** 14-21 Tage

---

## 3. Phase 6.1 – Audio-System & Sound-Effekte

### 3.1 Ziele

- ✅ Vollständiges Audio-Management-System
- ✅ 15+ Sound-Effekte für alle Interaktionen
- ✅ 3-5 Hintergrundmusik-Tracks (optional)
- ✅ Erweiterte Haptic-Feedback-Patterns
- ✅ Audio-Settings mit Toggles

### 3.2 Tasks

#### T6.1.1 – AudioManager-Service

**Datei:** `HaushaltsHero/Domain/Services/AudioManager.swift`

```swift
import AVFoundation
import UIKit

/// Centralized audio management for the app
class AudioManager: ObservableObject {
    static let shared = AudioManager()

    // MARK: - Published Properties

    @Published var soundEffectsEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEffectsEnabled, forKey: "soundEffectsEnabled") }
    }

    @Published var musicEnabled: Bool {
        didSet { UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled") }
    }

    @Published var hapticEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled") }
    }

    // MARK: - Private Properties

    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var currentTrack: MusicTrack?

    // MARK: - Initialization

    private init() {
        self.soundEffectsEnabled = UserDefaults.standard.bool(forKey: "soundEffectsEnabled")
        self.musicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
        self.hapticEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")

        preloadSoundEffects()
    }

    // MARK: - Sound Effects

    enum SoundEffect: String {
        // UI Interactions
        case buttonTap = "tap"
        case buttonPress = "press"
        case swipe = "swipe"
        case toggle = "toggle"

        // Camera & Photos
        case cameraShutter = "camera_shutter"
        case photoCapture = "photo_capture"
        case photoSave = "photo_save"

        // Scoring
        case scoreCalculating = "score_calculating"
        case scoreReveal = "score_reveal"
        case subscoreAppear = "subscore_appear"

        // Achievements & Rewards
        case questComplete = "quest_complete"
        case goalReached = "goal_reached"
        case levelUp = "level_up"
        case pointsEarn = "points_earn"
        case streakExtend = "streak_extend"
        case badge_unlock = "badge_unlock"

        // Feedback & Alerts
        case success = "success"
        case warning = "warning"
        case error = "error"
        case lowConfidence = "low_confidence"

        // Misc
        case heatmapReveal = "heatmap_reveal"
        case tipAppear = "tip_appear"
        case cardFlip = "card_flip"
    }

    func playSound(_ effect: SoundEffect) {
        guard soundEffectsEnabled else { return }

        if let player = soundEffectPlayers[effect] {
            player.currentTime = 0
            player.play()
        }
    }

    private func preloadSoundEffects() {
        for effect in SoundEffect.allCases {
            guard let url = Bundle.main.url(
                forResource: effect.rawValue,
                withExtension: "wav",
                subdirectory: "Resources/Media/Audio/SFX"
            ) else {
                print("⚠️ Sound effect not found: \(effect.rawValue)")
                continue
            }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                soundEffectPlayers[effect] = player
            } catch {
                print("❌ Failed to load sound: \(effect.rawValue) - \(error)")
            }
        }
    }

    // MARK: - Background Music

    enum MusicTrack: String {
        case ambient = "ambient_menu"
        case motivational = "motivational_challenge"
        case celebration = "celebration_victory"
        case dramatic = "dramatic_scoring"
        case relaxing = "relaxing_browse"
    }

    func playMusic(_ track: MusicTrack, loop: Bool = true) {
        guard musicEnabled else { return }

        // Stop current track
        musicPlayer?.stop()
        currentTrack = nil

        guard let url = Bundle.main.url(
            forResource: track.rawValue,
            withExtension: "mp3",
            subdirectory: "Resources/Media/Audio/Music"
        ) else {
            print("⚠️ Music track not found: \(track.rawValue)")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = loop ? -1 : 0
            musicPlayer?.volume = 0.3 // 30% volume
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            currentTrack = track
        } catch {
            print("❌ Failed to play music: \(track.rawValue) - \(error)")
        }
    }

    func stopMusic(fadeOut: Bool = true) {
        if fadeOut {
            fadeOutMusic()
        } else {
            musicPlayer?.stop()
            currentTrack = nil
        }
    }

    private func fadeOutMusic(duration: TimeInterval = 1.0) {
        guard let player = musicPlayer else { return }

        let steps = 20
        let volumeDecrement = player.volume / Float(steps)
        let stepDuration = duration / Double(steps)

        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            player.volume -= volumeDecrement

            if player.volume <= 0 {
                timer.invalidate()
                player.stop()
                player.volume = 0.3 // Reset for next time
                self.currentTrack = nil
            }
        }
    }

    // MARK: - Haptic Feedback

    enum HapticPattern {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case scoreReveal(score: Int)
        case levelUp
        case questComplete
    }

    func triggerHaptic(_ pattern: HapticPattern) {
        guard hapticEnabled else { return }

        switch pattern {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)

        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)

        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)

        case .scoreReveal(let score):
            // Dynamic haptic based on score
            switch score {
            case 85...100:
                // Double tap for excellent
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

            case 70..<85:
                // Single medium tap
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            default:
                // Light tap for improvement needed
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

        case .levelUp:
            // Triple tap pattern
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generator.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }

        case .questComplete:
            // Success notification
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// Make SoundEffect CaseIterable for preloading
extension AudioManager.SoundEffect: CaseIterable {}
```

**Aufwand:** 4-6 Stunden

---

#### T6.1.2 – Sound-Effekte Assets erstellen/beschaffen

**Asset-Quellen:**

1. **Kostenlos:**
   - [Freesound.org](https://freesound.org) - Creative Commons
   - [Zapsplat.com](https://zapsplat.com) - Free tier
   - [Mixkit.co](https://mixkit.co/free-sound-effects/) - Royalty-free

2. **Premium:**
   - [AudioJungle](https://audiojungle.net) - $1-5 pro Sound
   - [Epidemic Sound](https://epidemicsound.com) - Subscription
   - Custom-Creation via Fiverr ($5-20 pro Sound)

**Benötigte Sounds (Mindestens):**

| Kategorie | Sound | Format | Länge |
|-----------|-------|--------|-------|
| **UI** | Button Tap | WAV | <0.1s |
| | Button Press | WAV | <0.1s |
| | Swipe | WAV | <0.2s |
| | Toggle | WAV | <0.1s |
| **Camera** | Shutter | WAV | 0.2s |
| | Photo Save | WAV | 0.3s |
| **Scoring** | Calculating | WAV | 1-2s (loop) |
| | Score Reveal | WAV | 0.5s |
| | Subscore Pop | WAV | 0.2s |
| **Rewards** | Quest Complete | WAV | 1s |
| | Goal Reached | WAV | 1.5s |
| | Level Up | WAV | 2s |
| | Points Earn | WAV | 0.3s |
| | Streak Extend | WAV | 0.5s |
| | Badge Unlock | WAV | 1s |
| **Feedback** | Success | WAV | 0.5s |
| | Warning | WAV | 0.4s |
| | Error | WAV | 0.3s |
| **Misc** | Heatmap Reveal | WAV | 0.8s |
| | Tip Appear | WAV | 0.3s |

**Technische Specs:**
- Format: WAV (unkomprimiert) oder AAC (iOS-optimiert)
- Sample Rate: 44.1 kHz
- Bit Depth: 16-bit
- Mono (für SFX), Stereo (für Musik)
- Dateigröße: <100 KB pro Sound

**Aufwand:** 4-8 Stunden (Recherche, Download, Bearbeitung)

---

#### T6.1.3 – Hintergrundmusik erstellen/beschaffen

**Musik-Tracks:**

| Track | Mood | Verwendung | Länge |
|-------|------|------------|-------|
| Ambient Menu | Ruhig, Lofi | Hauptmenü, Settings | 2-3 min (Loop) |
| Motivational Challenge | Energetisch, Upbeat | Challenge-Start | 1-2 min |
| Celebration Victory | Triumphant, Freude | Quest/Goal Complete | 30-60s |
| Dramatic Scoring | Spannung, Build-up | Scoring-Phase | 1-2 min |
| Relaxing Browse | Entspannt, Soft | Micro-Learning, Quests | 2-3 min (Loop) |

**Quellen:**
- [Epidemic Sound](https://epidemicsound.com) - $15/Monat
- [Artlist](https://artlist.io) - $16/Monat
- [YouTube Audio Library](https://studio.youtube.com/channel/UC.../music) - Kostenlos
- [Incompetech](https://incompetech.com) - CC-BY (kostenlos mit Attribution)

**Technische Specs:**
- Format: MP3 (komprimiert) oder AAC (iOS-optimiert)
- Bitrate: 192 kbps
- Sample Rate: 44.1 kHz
- Stereo
- Dateigröße: 2-5 MB pro Track

**Aufwand:** 6-10 Stunden (Recherche, Lizenzierung, Integration)

---

#### T6.1.4 – Settings-UI erweitern

**Datei:** `HaushaltsHero/Presentation/Views/SettingsView.swift`

```swift
// In SettingsView hinzufügen:

@ObservedObject var audioManager = AudioManager.shared

Section(header: Text("🔊 Audio & Haptics")) {
    Toggle("Sound-Effekte", isOn: $audioManager.soundEffectsEnabled)
        .onChange(of: audioManager.soundEffectsEnabled) { newValue in
            if newValue {
                audioManager.playSound(.toggle)
            }
        }

    Toggle("Hintergrundmusik", isOn: $audioManager.musicEnabled)
        .onChange(of: audioManager.musicEnabled) { newValue in
            if newValue {
                audioManager.playMusic(.ambient)
            } else {
                audioManager.stopMusic()
            }
        }

    Toggle("Haptisches Feedback", isOn: $audioManager.hapticEnabled)
        .onChange(of: audioManager.hapticEnabled) { newValue in
            if newValue {
                audioManager.triggerHaptic(.medium)
            }
        }
}
```

**Aufwand:** 1-2 Stunden

---

#### T6.1.5 – Audio in Views integrieren

**Beispiel: ChallengeViewModel**

```swift
// In ChallengeViewModel.swift

func captureBeforePhoto(_ image: UIImage) {
    beforeImage = image
    flowState = .afterPhoto

    // Audio & Haptic
    AudioManager.shared.playSound(.photoCapture)
    AudioManager.shared.triggerHaptic(.medium)
}

func processChallenge() async {
    // ...

    // Start scoring music
    AudioManager.shared.playMusic(.dramatic, loop: false)
    AudioManager.shared.playSound(.scoreCalculating)

    // Calculate score...

    // Reveal score
    AudioManager.shared.playSound(.scoreReveal)
    AudioManager.shared.triggerHaptic(.scoreReveal(score: score.overallScore))

    if score.overallScore >= 85 {
        AudioManager.shared.playSound(.success)
    }

    flowState = .result
}
```

**Integration in:**
- ✅ ChallengeStartView (Button Taps)
- ✅ CameraFlowView (Photo Capture)
- ✅ ScoreResultView (Score Reveal, Subscores)
- ✅ QuestsView (Quest Complete)
- ✅ HabitCoachView (Goal Reached)
- ✅ MicroLearningView (Card Flip)

**Aufwand:** 4-6 Stunden

---

### 3.3 Phase 6.1 Deliverables

- ✅ `AudioManager.swift` (200+ Zeilen)
- ✅ 20+ Sound-Effekte (WAV-Dateien)
- ✅ 5 Musik-Tracks (MP3-Dateien)
- ✅ Erweiterte Settings-UI
- ✅ Integration in alle Views
- ✅ Unit-Tests für AudioManager

**Gesamt-Aufwand:** 2-3 Tage

---

## 4. Phase 6.2 – Lottie-Animationen & Hero-Character

### 4.1 Ziele

- ✅ Lottie-Integration via Swift Package Manager
- ✅ 10+ Lottie-Animationen (Confetti, Level-Up, etc.)
- ✅ Animierter Hero-Character mit 5 Emotionen
- ✅ Smooth Transitions & Performance-Optimierung

### 4.2 Tasks

#### T6.2.1 – Lottie SDK Integration

**Swift Package Manager:**

```swift
// In Xcode: File → Add Package Dependencies
// URL: https://github.com/airbnb/lottie-ios
// Version: 4.3.0+
```

**Package.swift (falls applicable):**

```swift
dependencies: [
    .package(url: "https://github.com/airbnb/lottie-ios", from: "4.3.0")
]
```

**Aufwand:** 30 Minuten

---

#### T6.2.2 – Lottie-Animationen Assets

**Quellen:**
- [LottieFiles.com](https://lottiefiles.com) - 100,000+ kostenlose Animationen
- [IconScout](https://iconscout.com/lottie-animations) - Premium
- Custom via After Effects + Bodymovin Plugin

**Benötigte Animationen:**

| Name | Verwendung | Quelle | Größe |
|------|------------|--------|-------|
| `confetti.json` | Quest Complete, High Score | LottieFiles | 50-100 KB |
| `level_up.json` | Streak Milestone, Badge Unlock | LottieFiles | 80-150 KB |
| `loading_spinner.json` | Scoring-Phase | LottieFiles | 30-50 KB |
| `checkmark_success.json` | Score > 85 | LottieFiles | 20-40 KB |
| `warning_icon.json` | Low Confidence | LottieFiles | 25-50 KB |
| `sparkles.json` | Heatmap Overlay | LottieFiles | 40-80 KB |
| `coin_collect.json` | Points Earned | LottieFiles | 50-100 KB |
| `trophy_award.json` | Goal Reached | LottieFiles | 60-120 KB |
| `fireworks.json` | Weekly Goal Complete | LottieFiles | 100-200 KB |
| `pulse_circle.json` | Button Highlight | LottieFiles | 15-30 KB |

**Hero-Character-Emotionen:**

| Emotion | Trigger | Animation |
|---------|---------|-----------|
| `hero_happy.json` | Score 85+ | Smile, Jump, Thumbs-up |
| `hero_encouraging.json` | Score 50-85 | Supportive Gesture |
| `hero_thinking.json` | Scoring-Phase | Hand on Chin, Pondering |
| `hero_celebrating.json` | Quest Complete | Dance, Confetti |
| `hero_tired.json` | Inaktivität >7 Tage | Yawn, Sad Face |

**Custom Hero-Character:**
- Option 1: LottieFiles durchsuchen (Stichwort: "mascot", "character")
- Option 2: Fiverr Artist beauftragen ($50-200 für 5 Animationen)
- Option 3: After Effects selbst erstellen (erfordert Skills)

**Aufwand:** 6-10 Stunden (Recherche, Download, ggf. Anpassung)

---

#### T6.2.3 – LottieView Wrapper

**Datei:** `HaushaltsHero/Presentation/Components/LottieView.swift`

```swift
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()

        // Load animation from bundle
        if let animation = LottieAnimation.named(
            animationName,
            subdirectory: "Resources/Media/Animations"
        ) {
            animationView.animation = animation
            animationView.loopMode = loopMode
            animationView.animationSpeed = animationSpeed
            animationView.contentMode = contentMode
            animationView.play()
        } else {
            print("⚠️ Lottie animation not found: \(animationName)")
        }

        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Update if needed
    }
}

// Convenience Extension
extension LottieView {
    static func confetti() -> LottieView {
        LottieView(animationName: "confetti", loopMode: .playOnce)
    }

    static func loading() -> LottieView {
        LottieView(animationName: "loading_spinner", loopMode: .loop)
    }

    static func hero(emotion: HeroEmotion) -> LottieView {
        LottieView(animationName: "hero_\(emotion.rawValue)", loopMode: .playOnce)
    }
}

enum HeroEmotion: String {
    case happy, encouraging, thinking, celebrating, tired
}
```

**Aufwand:** 2-3 Stunden

---

#### T6.2.4 – Hero-Character Integration

**Datei:** `HaushaltsHero/Presentation/Components/HeroCharacterView.swift`

```swift
import SwiftUI

struct HeroCharacterView: View {
    let emotion: HeroEmotion
    let size: CGFloat

    init(emotion: HeroEmotion, size: CGFloat = 120) {
        self.emotion = emotion
        self.size = size
    }

    var body: some View {
        LottieView.hero(emotion: emotion)
            .frame(width: size, height: size)
    }
}

// Usage in ScoreResultView:
struct ScoreResultView: View {
    @ObservedObject var viewModel: ChallengeViewModel

    var body: some View {
        VStack {
            // Hero appears based on score
            HeroCharacterView(
                emotion: heroEmotion(for: viewModel.currentScore?.overallScore ?? 0),
                size: 150
            )

            // Score display...
        }
    }

    func heroEmotion(for score: Int) -> HeroEmotion {
        switch score {
        case 85...100: return .celebrating
        case 70..<85: return .happy
        case 50..<70: return .encouraging
        default: return .encouraging
        }
    }
}
```

**Integration in:**
- ✅ ScoreResultView (Score-basierte Emotion)
- ✅ HomeView (Idle Animation)
- ✅ QuestsView (Quest Complete Celebration)
- ✅ HabitCoachView (Encouragement)

**Aufwand:** 3-4 Stunden

---

#### T6.2.5 – Konfetti-Effekt bei Erfolgen

**Datei:** `HaushaltsHero/Presentation/Components/ConfettiView.swift`

```swift
import SwiftUI

struct ConfettiView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            if isAnimating {
                LottieView.confetti()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            isAnimating = true

            // Auto-hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isAnimating = false
            }
        }
    }
}

// Usage:
.overlay(
    ConfettiView()
        .opacity(showConfetti ? 1 : 0)
)
```

**Aufwand:** 1-2 Stunden

---

### 4.3 Phase 6.2 Deliverables

- ✅ Lottie SDK Integration
- ✅ 10+ Lottie-Animationen (JSON-Dateien)
- ✅ 5 Hero-Character-Animationen
- ✅ LottieView Wrapper
- ✅ HeroCharacterView Component
- ✅ ConfettiView Component
- ✅ Integration in 5+ Views

**Gesamt-Aufwand:** 3-4 Tage

---

## 5. Phase 6.3 – Video-Tutorials & Micro-Learning

### 5.1 Ziele

- ✅ 5-10 Tutorial-Videos (30-60s je)
- ✅ VideoPlayer-Integration in Micro-Learning
- ✅ Offline-Verfügbarkeit (gebündelt in App)
- ✅ Optional: Cloud-Hosting für spätere Videos

### 5.2 Tasks

#### T6.3.1 – Video-Content erstellen

**Tutorial-Themen:**

| Video | Thema | Länge | Format |
|-------|-------|-------|--------|
| 1 | Spiegel streifenfrei putzen | 45s | MP4 (H.264) |
| 2 | Toilette gründlich reinigen | 60s | MP4 (H.264) |
| 3 | Zimmer effizient aufräumen | 50s | MP4 (H.264) |
| 4 | Beste Foto-Techniken für hohe Scores | 40s | MP4 (H.264) |
| 5 | Heatmap richtig interpretieren | 30s | MP4 (H.264) |
| 6 | Quests optimal nutzen | 35s | MP4 (H.264) |
| 7 | Streak aufbauen & halten | 40s | MP4 (H.264) |

**Produktions-Optionen:**

1. **DIY (Kostenlos):**
   - iPhone-Kamera + iMovie
   - Screen-Recording + Voiceover
   - Stock-Footage + Text-Overlays

2. **Outsourcing (Premium):**
   - Fiverr: $50-200 pro Video
   - Upwork: $100-500 pro Video
   - Professionelle Agentur: $500-2000 pro Video

3. **Stock-Videos:**
   - [Pexels Videos](https://pexels.com/videos) - Kostenlos
   - [Videvo](https://videvo.net) - Kostenlos + Premium
   - [Artgrid](https://artgrid.io) - Premium ($30/Monat)

**Technische Specs:**
- Format: MP4 (H.264 Codec)
- Auflösung: 1080p (1920x1080)
- Frame Rate: 30 fps
- Bitrate: 5-8 Mbps
- Audio: AAC, 128 kbps
- Dateigröße: 5-15 MB pro Video (30-60s)

**Aufwand:** 8-16 Stunden (Konzept, Dreh, Schnitt, Encoding)

---

#### T6.3.2 – VideoPlayerView Component

**Datei:** `HaushaltsHero/Presentation/Components/VideoPlayerView.swift`

```swift
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    let fileExtension: String

    @State private var player: AVPlayer?

    init(videoName: String, fileExtension: String = "mp4") {
        self.videoName = videoName
        self.fileExtension = fileExtension
    }

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 220)
                    .cornerRadius(12)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView("Video wird geladen...")
                    .frame(height: 220)
            }
        }
        .onAppear {
            loadVideo()
        }
    }

    private func loadVideo() {
        guard let url = Bundle.main.url(
            forResource: videoName,
            withExtension: fileExtension,
            subdirectory: "Resources/Media/Video/Tutorials"
        ) else {
            print("⚠️ Video not found: \(videoName).\(fileExtension)")
            return
        }

        player = AVPlayer(url: url)
    }
}
```

**Aufwand:** 2-3 Stunden

---

#### T6.3.3 – Micro-Learning erweitern mit Videos

**Datei:** `HaushaltsHero/Resources/Content/microlearning.json`

```json
{
  "id": "ml-001",
  "title": "Spiegel streifenfrei putzen",
  "content": "Verwende ein Mikrofasertuch und kreisende Bewegungen...",
  "category": "mirror",
  "tags": ["reinigung", "technik", "spiegel"],
  "videoFileName": "mirror_cleaning",  // NEU
  "videoDuration": 45  // Sekunden
}
```

**Model-Update:** `MicroLearningCard.swift`

```swift
struct MicroLearningCard: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let category: ChallengeCategory
    let tags: [String]
    let videoFileName: String?  // NEU
    let videoDuration: Int?     // NEU (Sekunden)
}
```

**View-Update:** `MicroLearningView.swift`

```swift
// In Card-Detail-View:
if let videoFileName = card.videoFileName {
    VideoPlayerView(videoName: videoFileName)
        .padding()
}

Text(card.content)
    .font(.body)
```

**Aufwand:** 3-4 Stunden

---

### 5.3 Phase 6.3 Deliverables

- ✅ 5-7 Tutorial-Videos (MP4, gebündelt)
- ✅ VideoPlayerView Component
- ✅ MicroLearningCard-Model erweitert
- ✅ Integration in MicroLearningView
- ✅ Video-Thumbnails (optional)

**Gesamt-Aufwand:** 3-5 Tage

---

## 6. Phase 6.4 – Advanced Features (Optional)

### 6.1 Time-Lapse-Generator

**Datei:** `HaushaltsHero/Domain/Services/TimeLapseGenerator.swift`

**Funktionalität:**
- Alle Nachher-Fotos der Woche → 5-10s Video
- Musik-Overlay
- Score-Text-Overlay
- Teilen-Funktion

**Technologie:** AVFoundation (AVMutableComposition)

**Aufwand:** 1-2 Tage

---

### 6.2 Before/After Comparison Video

**Automatisches Video:**
- 2s Before-Foto
- 1s Transition (Wipe/Fade)
- 2s After-Foto
- Score-Overlay einblenden

**Aufwand:** 1 Tag

---

### 6.3 AR-Vorschau (iOS 17+, Vision Pro)

**Konzept:**
- ARKit-Scan des Raums
- AI-generiertes "Nachher"-Preview
- "So könnte es aussehen"-Overlay

**Aufwand:** 3-5 Tage

---

## 7. Phase 6.5 – Asset-Optimierung & Performance

### 7.1 Tasks

#### T6.5.1 – Asset-Komprimierung

**Audio:**
```bash
# FFmpeg für Audio-Komprimierung
ffmpeg -i input.wav -c:a aac -b:a 128k output.aac
```

**Video:**
```bash
# Video auf iOS optimieren
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 128k output.mp4
```

**Lottie:**
- Lottie-Animationen via LottieFiles-Optimizer
- Unnötige Layers entfernen
- Farbpaletten reduzieren

**Aufwand:** 4-6 Stunden

---

#### T6.5.2 – Lazy Loading & Caching

```swift
// Audio preloading nur für häufig genutzte Sounds
// Videos on-demand laden
// Lottie-Animationen im Memory-Cache
```

**Aufwand:** 2-3 Stunden

---

#### T6.5.3 – Performance-Tests

- App-Start-Zeit: <2s (trotz Assets)
- Memory-Footprint: <150 MB
- Audio-Latenz: <50ms
- Lottie-Rendering: 60 fps

**Aufwand:** 3-4 Stunden

---

### 7.2 Phase 6.5 Deliverables

- ✅ Alle Assets optimiert
- ✅ Lazy-Loading implementiert
- ✅ Performance-Benchmarks
- ✅ Bundle-Size-Report

**Gesamt-Aufwand:** 1-2 Tage

---

## 8. Asset-Struktur (Final)

```
HaushaltsHero/Resources/Media/
├── Audio/
│   ├── Music/
│   │   ├── ambient_menu.mp3
│   │   ├── motivational_challenge.mp3
│   │   ├── celebration_victory.mp3
│   │   ├── dramatic_scoring.mp3
│   │   └── relaxing_browse.mp3
│   └── SFX/
│       ├── tap.wav
│       ├── camera_shutter.wav
│       ├── score_reveal.wav
│       ├── quest_complete.wav
│       ├── level_up.wav
│       ├── points_earn.wav
│       ├── success.wav
│       ├── warning.wav
│       └── error.wav
├── Video/
│   └── Tutorials/
│       ├── mirror_cleaning.mp4
│       ├── toilet_cleaning.mp4
│       ├── room_organization.mp4
│       ├── photo_tips.mp4
│       └── heatmap_guide.mp4
└── Animations/
    ├── confetti.json
    ├── level_up.json
    ├── loading_spinner.json
    ├── checkmark_success.json
    ├── sparkles.json
    ├── hero_happy.json
    ├── hero_encouraging.json
    ├── hero_thinking.json
    ├── hero_celebrating.json
    └── hero_tired.json
```

**Bundle-Größe (geschätzt):**
- Audio: 15-25 MB
- Video: 50-70 MB
- Animations: 2-5 MB
- **Gesamt:** 70-100 MB

---

## 9. Priorisierung & Roadmap

### Empfohlene Reihenfolge

**Sprint 1 (Woche 1):**
- ✅ Phase 6.1.1-6.1.3: AudioManager + Sound-Effekte (Quick-Win)
- ✅ Phase 6.2.1-6.2.3: Lottie-Integration + Basic-Animationen

**Sprint 2 (Woche 2):**
- ✅ Phase 6.1.4-6.1.5: Audio-Integration in Views
- ✅ Phase 6.2.4-6.2.5: Hero-Character + Konfetti

**Sprint 3 (Woche 3):**
- ✅ Phase 6.3.1-6.3.3: Video-Tutorials + Micro-Learning
- ✅ Phase 6.5: Asset-Optimierung

**Optional (Woche 4+):**
- ⏸️ Phase 6.4: Advanced Features (Time-Lapse, AR)

---

## 10. Success-Criteria

| Kriterium | Zielwert |
|-----------|----------|
| **User Engagement** | +30% durch Multimedia |
| **Session Duration** | +20% durch Videos/Animationen |
| **App-Start-Zeit** | <2s (trotz Assets) |
| **Memory-Usage** | <150 MB |
| **Bundle-Größe** | <200 MB (inklusive Assets) |
| **Positive Feedback** | 80%+ mögen Audio/Video |

---

## 11. Risiken & Mitigations

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|-------------------|--------|------------|
| **Bundle zu groß** | Hoch | Mittel | On-Demand-Download für Videos |
| **Performance-Issues** | Mittel | Hoch | Lazy-Loading, Asset-Optimierung |
| **Lizenz-Probleme** | Niedrig | Hoch | Nur CC0/Royalty-Free Assets |
| **Nutzer deaktivieren Audio** | Hoch | Niedrig | Toggles in Settings (bereits geplant) |

---

## 12. Nächste Schritte

1. ✅ Plan-Review & Freigabe
2. ✅ Asset-Beschaffung beginnen (LottieFiles, Freesound)
3. ✅ Sprint 1 starten: AudioManager + Lottie-Integration
4. ✅ Kontinuierliches Testing auf echtem Device (Performance!)

---

**Erstellt von:** AI Agent
**Review durch:** Team (ausstehend)
**Nächste Review:** Nach Sprint 1 (AudioManager + Lottie fertig)
