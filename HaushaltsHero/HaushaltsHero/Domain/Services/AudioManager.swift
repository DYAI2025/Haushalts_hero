//
//  AudioManager.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-19.
//

import AVFoundation
import UIKit

/// Centralized audio management for the app
class AudioManager: ObservableObject {
    static let shared = AudioManager()

    // MARK: - Published Properties

    @Published var soundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEffectsEnabled, forKey: "soundEffectsEnabled")
        }
    }

    @Published var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
            if !musicEnabled {
                stopMusic()
            }
        }
    }

    @Published var hapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled")
        }
    }

    // MARK: - Private Properties

    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var currentTrack: MusicTrack?

    // MARK: - Initialization

    private init() {
        // Load settings from UserDefaults (default: true)
        self.soundEffectsEnabled = UserDefaults.standard.object(forKey: "soundEffectsEnabled") as? Bool ?? true
        self.musicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") as? Bool ?? false // Music off by default
        self.hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true

        // Configure audio session
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Sound Effects

    enum SoundEffect: String, CaseIterable {
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
        case badgeUnlock = "badge_unlock"

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

        // For MVP: Use system sounds as placeholders
        // In production: Load actual WAV files
        let systemSoundID: SystemSoundID = {
            switch effect {
            case .buttonTap, .toggle:
                return 1104 // Tock
            case .buttonPress:
                return 1105 // Click
            case .cameraShutter, .photoCapture:
                return 1108 // Camera shutter
            case .success, .questComplete, .goalReached:
                return 1025 // Success chime
            case .warning, .lowConfidence:
                return 1053 // Warning beep
            case .error:
                return 1073 // Alert
            case .scoreReveal, .levelUp:
                return 1016 // Anticipate
            case .pointsEarn, .badgeUnlock:
                return 1013 // Coin
            default:
                return 1104 // Default tock
            }
        }()

        AudioServicesPlaySystemSound(systemSoundID)
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

        // Stop current track if different
        if currentTrack != track {
            musicPlayer?.stop()
        }

        // For MVP: Music files are optional
        // This will gracefully fail if files don't exist
        guard let url = Bundle.main.url(
            forResource: track.rawValue,
            withExtension: "mp3",
            subdirectory: "Resources/Media/Audio/Music"
        ) else {
            // Silent fail - music is optional
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
            print("⚠️ Could not play music: \(track.rawValue)")
        }
    }

    func stopMusic(fadeOut: Bool = true) {
        if fadeOut && musicPlayer?.isPlaying == true {
            fadeOutMusic()
        } else {
            musicPlayer?.stop()
            currentTrack = nil
        }
    }

    private func fadeOutMusic(duration: TimeInterval = 1.0) {
        guard let player = musicPlayer, player.isPlaying else { return }

        let steps = 20
        let volumeDecrement = player.volume / Float(steps)
        let stepDuration = duration / Double(steps)

        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            player.volume -= volumeDecrement

            if currentStep >= steps || player.volume <= 0 {
                timer.invalidate()
                player.stop()
                player.volume = 0.3 // Reset for next time
                self.currentTrack = nil
            }
        }
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func resumeMusic() {
        guard musicEnabled else { return }
        musicPlayer?.play()
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
            // Success notification + impact
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }

    // MARK: - Convenience Methods

    /// Play a combination of sound + haptic for common actions
    func playFeedback(sound: SoundEffect, haptic: HapticPattern) {
        playSound(sound)
        triggerHaptic(haptic)
    }
}
