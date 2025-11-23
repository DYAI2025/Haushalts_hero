//
//  ScoreResultView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// View for displaying challenge results with explainable score
struct ScoreResultView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ChallengeViewModel
    @EnvironmentObject var container: AppContainer
    @State private var showSubscores = false
    @State private var showMicroLearning = false
    @State private var showConfetti = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                if viewModel.isProcessing {
                    ProcessingView()
                } else if let score = viewModel.currentScore {
                    // Hero Character (reacts to score)
                    HeroCharacterView(
                        emotion: HeroEmotion.forScore(score.overallScore),
                        size: 140,
                        showSpeechBubble: true
                    )
                    .padding(.top)

                    // Score Display
                    ScoreHeader(score: score)
                        .onAppear {
                            // Trigger confetti for high scores
                            if score.overallScore >= 85 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showConfetti = true
                                }
                            }
                        }

                    // Heatmap (if available)
                    if let afterImage = viewModel.afterImage, score.heatmapData != nil {
                        HeatmapOverlayView(
                            image: afterImage,
                            heatmapData: score.heatmapData
                        )
                    }

                    // Subscores
                    SubscoresSection(
                        score: score,
                        isExpanded: $showSubscores
                    )

                    // Explanation
                    ExplanationSection(explanation: score.explanation)

                    // Confidence Indicator
                    ConfidenceSection(score: score)

                    // Coaching Section
                    CoachingSectionView(
                        score: score,
                        repository: container.repository
                    )

                    // Micro Learning Link
                    Button(action: { showMicroLearning = true }) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.purple)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mehr lernen")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("20+ Wissenskarten entdecken")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 8)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    // Actions
                    ActionButtons(viewModel: viewModel, score: score)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error, viewModel: viewModel)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showMicroLearning) {
            MicroLearningView(repository: container.repository)
        }
        .confetti(isPresented: $showConfetti, duration: 3.0)
    }
}

// MARK: - Processing View

struct ProcessingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()

            Text("Analysiere deine Challenge...")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Einen Moment bitte")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Score Header

struct ScoreHeader: View {
    let score: ExplainableScore

    var body: some View {
        VStack(spacing: 16) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: CGFloat(score.overallScore) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: score.overallScore)

                VStack(spacing: 4) {
                    Text("\(score.overallScore)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(scoreColor)

                    Text("Punkte")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 20)

            // Score Level
            HStack(spacing: 8) {
                Text(score.scoreLevel.emoji)
                    .font(.title)

                Text(score.scoreLevel.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }

    private var scoreColor: Color {
        switch score.scoreLevel {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }
}

// MARK: - Subscores Section

struct SubscoresSection: View {
    let score: ExplainableScore
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("Detailbewertung")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }

            // Subscores
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(score.subscores) { subscore in
                        SubscoreRow(subscore: subscore)
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct SubscoreRow: View {
    let subscore: Subscore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(subscore.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(subscore.value)")
                    .font(.headline)
                    .foregroundColor(subscoreColor)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(subscoreColor)
                        .frame(width: geometry.size.width * CGFloat(subscore.value) / 100, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: subscore.value)
                }
            }
            .frame(height: 8)

            Text(subscore.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private var subscoreColor: Color {
        switch subscore.value {
        case 85...100: return .green
        case 70..<85: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}

// MARK: - Explanation Section

struct ExplanationSection: View {
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Feedback")
                    .font(.headline)
            }

            Text(explanation)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Confidence Section

struct ConfidenceSection: View {
    let score: ExplainableScore

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(confidenceColor)

            VStack(alignment: .leading, spacing: 4) {
                Text("Bewertungs-Sicherheit")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(score.confidenceLevel.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(Int(score.confidence * 100))%")
                .font(.headline)
                .foregroundColor(confidenceColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private var confidenceColor: Color {
        switch score.confidenceLevel {
        case .high: return .green
        case .medium: return .orange
        case .low: return .red
        }
    }
}

// MARK: - Action Buttons

struct ActionButtons: View {
    @ObservedObject var viewModel: ChallengeViewModel
    let score: ExplainableScore

    var body: some View {
        VStack(spacing: 12) {
            // Show retry option for low confidence
            if score.confidenceLevel == .low {
                Button(action: {
                    viewModel.retryChallenge()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Fotos neu aufnehmen")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange)
                    )
                }

                Text("Die Bewertung ist unsicher. Neue Fotos können ein besseres Ergebnis liefern.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Complete button
            Button(action: {
                viewModel.completeChallenge()
            }) {
                Text(score.confidenceLevel == .low ? "Trotzdem abschließen" : "Challenge abschließen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
        }
        .padding(.top)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    @ObservedObject var viewModel: ChallengeViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Fehler")
                .font(.title)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                viewModel.retryChallenge()
            }) {
                Text("Nochmal versuchen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ChallengeViewModel(repository: LocalRepository())

    // Mock score for preview
    let mockScore = ExplainableScore(
        overallScore: 82,
        subscores: [
            Subscore(name: "Streifenfreiheit", value: 85, weight: 0.4, description: "Keine sichtbaren Streifen"),
            Subscore(name: "Klarheit", value: 78, weight: 0.35, description: "Klare Oberfläche"),
            Subscore(name: "Gleichmäßigkeit", value: 84, weight: 0.25, description: "Gleichmäßige Reinigung")
        ],
        confidence: 0.85,
        explanation: "Du hast ein sehr gutes Ergebnis erzielt. Weiter so!",
        heatmapData: nil
    )

    viewModel.currentScore = mockScore

    return ScoreResultView(viewModel: viewModel)
}
