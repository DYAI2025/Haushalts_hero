//
//  HeroCharacterView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-19.
//

import SwiftUI

/// Animated hero character that reacts to user actions and scores
struct HeroCharacterView: View {
    let emotion: HeroEmotion
    let size: CGFloat
    let showSpeechBubble: Bool

    init(
        emotion: HeroEmotion,
        size: CGFloat = 120,
        showSpeechBubble: Bool = false
    ) {
        self.emotion = emotion
        self.size = size
        self.showSpeechBubble = showSpeechBubble
    }

    var body: some View {
        VStack(spacing: 12) {
            // Lottie Animation (or placeholder)
            LottieView.hero(emotion: emotion)
                .frame(width: size, height: size)

            // Optional speech bubble
            if showSpeechBubble {
                SpeechBubble(message: speechMessage)
            }
        }
    }

    private var speechMessage: String {
        switch emotion {
        case .happy:
            return "Super gemacht! 🌟"
        case .celebrating:
            return "Wow! Du bist ein Star! 🎉"
        case .thinking:
            return "Hmm, lass mich nachdenken... 🤔"
        case .encouraging:
            return "Du schaffst das! 💪"
        case .tired:
            return "Lange nicht gesehen! Zeit für eine Challenge? 😴"
        }
    }
}

// MARK: - Speech Bubble Component

struct SpeechBubble: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // Bubble background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                    // Tail (triangle pointing down)
                    Triangle()
                        .fill(Color(.systemBackground))
                        .frame(width: 12, height: 8)
                        .offset(y: 20)
                }
            )
            .padding(.horizontal, 20)
    }
}

// MARK: - Triangle Shape for Speech Bubble Tail

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Emotion Selection Helper

extension HeroEmotion {
    /// Select emotion based on score
    static func forScore(_ score: Int) -> HeroEmotion {
        switch score {
        case 85...100:
            return .celebrating
        case 70..<85:
            return .happy
        case 50..<70:
            return .encouraging
        default:
            return .encouraging
        }
    }

    /// Select emotion based on confidence
    static func forConfidence(_ confidence: Double) -> HeroEmotion {
        if confidence >= 0.8 {
            return .happy
        } else if confidence >= 0.6 {
            return .thinking
        } else {
            return .encouraging
        }
    }

    /// Select emotion based on streak
    static func forStreak(_ streakCount: Int) -> HeroEmotion {
        switch streakCount {
        case 5...:
            return .celebrating
        case 3..<5:
            return .happy
        case 1..<3:
            return .encouraging
        default:
            return .tired
        }
    }
}

// MARK: - Preview

#Preview("Hero Emotions") {
    VStack(spacing: 20) {
        ForEach(HeroEmotion.allCases, id: \.self) { emotion in
            HeroCharacterView(
                emotion: emotion,
                size: 100,
                showSpeechBubble: true
            )
        }
    }
    .padding()
}
