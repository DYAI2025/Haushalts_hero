//
//  LottieView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-19.
//

import SwiftUI

// MARK: - Lottie Integration Instructions
/*
 TO ENABLE LOTTIE ANIMATIONS:

 1. In Xcode, go to: File → Add Package Dependencies
 2. Enter URL: https://github.com/airbnb/lottie-ios
 3. Select version: 4.3.0 or later
 4. Add to target: HaushaltsHero

 5. Uncomment the #if LOTTIE_ENABLED blocks below
 6. Comment out the placeholder implementations
 7. Add Lottie JSON files to: HaushaltsHero/Resources/Media/Animations/

 Example JSON files (download from lottiefiles.com):
 - confetti.json
 - level_up.json
 - loading_spinner.json
 - checkmark_success.json
 - sparkles.json
 - hero_happy.json
 - hero_celebrating.json
 - hero_thinking.json
 - hero_encouraging.json
 - hero_tired.json
*/

// MARK: - Lottie-Enabled Implementation (Uncomment after adding Lottie SDK)

/*
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
*/

// MARK: - Placeholder Implementation (Remove after enabling Lottie)

/// Placeholder view for Lottie animations (uses SF Symbols)
struct LottieView: View {
    let animationName: String
    var loopMode: LoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0
    var contentMode: ContentMode = .fit

    enum LoopMode {
        case playOnce, loop
    }

    var body: some View {
        // Placeholder: Show SF Symbol based on animation name
        let symbolName: String = {
            switch animationName {
            case "confetti":
                return "party.popper.fill"
            case "level_up":
                return "arrow.up.circle.fill"
            case "loading_spinner":
                return "arrow.triangle.2.circlepath"
            case "checkmark_success":
                return "checkmark.circle.fill"
            case "sparkles":
                return "sparkles"
            case _ where animationName.contains("hero"):
                return "figure.wave"
            default:
                return "star.fill"
            }
        }()

        Image(systemName: symbolName)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .opacity(loopMode == .loop ? 0.8 : 1.0)
    }
}

// MARK: - Convenience Extensions

extension LottieView {
    /// Confetti animation for celebrations
    static func confetti() -> LottieView {
        LottieView(animationName: "confetti", loopMode: .playOnce)
    }

    /// Loading spinner animation
    static func loading() -> LottieView {
        LottieView(animationName: "loading_spinner", loopMode: .loop, animationSpeed: 1.5)
    }

    /// Success checkmark animation
    static func success() -> LottieView {
        LottieView(animationName: "checkmark_success", loopMode: .playOnce)
    }

    /// Sparkles animation
    static func sparkles() -> LottieView {
        LottieView(animationName: "sparkles", loopMode: .loop)
    }

    /// Hero character with emotion
    static func hero(emotion: HeroEmotion) -> LottieView {
        LottieView(animationName: "hero_\(emotion.rawValue)", loopMode: .playOnce)
    }
}

// MARK: - Hero Emotion Types

enum HeroEmotion: String, CaseIterable {
    case happy
    case celebrating
    case thinking
    case encouraging
    case tired

    var description: String {
        switch self {
        case .happy: return "Fröhlich"
        case .celebrating: return "Feiernd"
        case .thinking: return "Nachdenklich"
        case .encouraging: return "Ermutigend"
        case .tired: return "Müde"
        }
    }
}
