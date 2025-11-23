//
//  ConfettiView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-19.
//

import SwiftUI

/// Confetti animation overlay for celebrations
struct ConfettiView: View {
    @State private var isAnimating = false
    let duration: TimeInterval

    init(duration: TimeInterval = 3.0) {
        self.duration = duration
    }

    var body: some View {
        ZStack {
            if isAnimating {
                // Lottie confetti animation (or placeholder)
                LottieView.confetti()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                isAnimating = true
            }

            // Auto-hide after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Confetti Particles (Fallback Animation)

/// SwiftUI-native confetti particles (used when Lottie is not available)
struct ConfettiParticles: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                animateParticles()
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]

        particles = (0..<50).map { index in
            ConfettiParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 4...12),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        for index in particles.indices {
            withAnimation(
                .easeOut(duration: Double.random(in: 2.0...4.0))
                .delay(Double.random(in: 0...0.5))
            ) {
                particles[index].position.y += UIScreen.main.bounds.height + 100
                particles[index].opacity = 0
            }
        }
    }
}

// MARK: - Confetti Particle Model

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

// MARK: - View Extension for Easy Usage

extension View {
    /// Add confetti overlay when condition is true
    func confetti(isPresented: Binding<Bool>, duration: TimeInterval = 3.0) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    ConfettiView(duration: duration)
                        .onAppear {
                            // Auto-dismiss after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                isPresented.wrappedValue = false
                            }
                        }
                }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        VStack {
            Text("Congratulations! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Quest Complete!")
                .font(.title2)
        }
    }
    .confetti(isPresented: .constant(true))
}
