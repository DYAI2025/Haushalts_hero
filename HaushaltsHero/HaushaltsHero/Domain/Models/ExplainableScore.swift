//
//  ExplainableScore.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// Represents a scoring result with subscores and explanation
struct ExplainableScore: Codable, Equatable {
    let overallScore: Int        // 0-100
    let subscores: [Subscore]
    let confidence: Double       // 0.0-1.0
    let explanation: String
    let heatmapData: HeatmapData?

    init(
        overallScore: Int,
        subscores: [Subscore],
        confidence: Double,
        explanation: String,
        heatmapData: HeatmapData? = nil
    ) {
        self.overallScore = overallScore
        self.subscores = subscores
        self.confidence = confidence
        self.explanation = explanation
        self.heatmapData = heatmapData
    }

    /// Confidence level classification
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.0..<0.5:
            return .low
        case 0.5..<0.75:
            return .medium
        case 0.75...1.0:
            return .high
        default:
            return .low
        }
    }

    /// Score level for UI styling
    var scoreLevel: ScoreLevel {
        switch overallScore {
        case 0..<50:
            return .poor
        case 50..<70:
            return .fair
        case 70..<85:
            return .good
        case 85...100:
            return .excellent
        default:
            return .poor
        }
    }
}

/// Individual subscore component
struct Subscore: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let value: Int              // 0-100
    let weight: Double          // 0.0-1.0
    let description: String

    init(
        id: UUID = UUID(),
        name: String,
        value: Int,
        weight: Double,
        description: String
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.weight = weight
        self.description = description
    }
}

/// Confidence level classification
enum ConfidenceLevel: String, Codable {
    case low = "Niedrig"
    case medium = "Mittel"
    case high = "Hoch"

    var color: String {
        switch self {
        case .low: return "red"
        case .medium: return "orange"
        case .high: return "green"
        }
    }
}

/// Score level for UI feedback
enum ScoreLevel: String, Codable {
    case poor = "Verbesserungsbedarf"
    case fair = "Okay"
    case good = "Gut"
    case excellent = "Hervorragend"

    var color: String {
        switch self {
        case .poor: return "red"
        case .fair: return "orange"
        case .good: return "blue"
        case .excellent: return "green"
        }
    }

    var emoji: String {
        switch self {
        case .poor: return "😐"
        case .fair: return "🙂"
        case .good: return "😊"
        case .excellent: return "🌟"
        }
    }
}

/// Heatmap data for visualization
struct HeatmapData: Codable, Equatable {
    let width: Int
    let height: Int
    let intensityMap: [[Double]]  // 2D array of intensity values 0.0-1.0

    init(width: Int, height: Int, intensityMap: [[Double]]) {
        self.width = width
        self.height = height
        self.intensityMap = intensityMap
    }
}
