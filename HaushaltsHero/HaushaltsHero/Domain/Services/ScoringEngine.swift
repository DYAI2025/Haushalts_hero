//
//  ScoringEngine.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import UIKit
import Vision

/// Engine for calculating scores from before/after photos
class ScoringEngine {

    // MARK: - Public Methods

    /// Calculate an explainable score from before/after photos
    /// - Parameters:
    ///   - beforeImage: The "before" photo
    ///   - afterImage: The "after" photo
    ///   - category: The challenge category
    /// - Returns: An ExplainableScore with subscores and explanation
    func calculateScore(
        beforeImage: UIImage,
        afterImage: UIImage,
        category: ChallengeCategory
    ) async -> ExplainableScore {
        // For MVP: Use heuristic scoring based on image analysis
        // Future: Replace with CoreML model or Vision API

        let subscores = await calculateSubscores(
            beforeImage: beforeImage,
            afterImage: afterImage,
            category: category
        )

        let overallScore = calculateOverallScore(from: subscores)
        let confidence = calculateConfidence(from: subscores, category: category)
        let explanation = generateExplanation(
            overallScore: overallScore,
            subscores: subscores,
            category: category
        )

        let heatmapData = await generateHeatmap(
            beforeImage: beforeImage,
            afterImage: afterImage
        )

        return ExplainableScore(
            overallScore: overallScore,
            subscores: subscores,
            confidence: confidence,
            explanation: explanation,
            heatmapData: heatmapData
        )
    }

    // MARK: - Private Methods

    /// Calculate individual subscores
    private func calculateSubscores(
        beforeImage: UIImage,
        afterImage: UIImage,
        category: ChallengeCategory
    ) async -> [Subscore] {
        // Heuristic scoring for MVP
        // Future: Use Vision API or CoreML

        let brightness = await analyzeBrightnessDifference(before: beforeImage, after: afterImage)
        let clarity = await analyzeClarity(image: afterImage)
        let uniformity = await analyzeUniformity(image: afterImage)

        var subscores: [Subscore] = []

        switch category {
        case .mirror:
            subscores = [
                Subscore(
                    name: "Streifenfreiheit",
                    value: Int(brightness * 100),
                    weight: 0.4,
                    description: "Keine sichtbaren Streifen oder Schlieren"
                ),
                Subscore(
                    name: "Klarheit",
                    value: Int(clarity * 100),
                    weight: 0.35,
                    description: "Klare, reflektierende Oberfläche"
                ),
                Subscore(
                    name: "Gleichmäßigkeit",
                    value: Int(uniformity * 100),
                    weight: 0.25,
                    description: "Gleichmäßige Reinigung über die gesamte Fläche"
                )
            ]

        case .toilet:
            subscores = [
                Subscore(
                    name: "Sauberkeit",
                    value: Int(brightness * 100),
                    weight: 0.45,
                    description: "Entfernung von Verschmutzungen"
                ),
                Subscore(
                    name: "Detailgrad",
                    value: Int(clarity * 100),
                    weight: 0.35,
                    description: "Gründlichkeit in schwer erreichbaren Bereichen"
                ),
                Subscore(
                    name: "Glanz",
                    value: Int(uniformity * 100),
                    weight: 0.2,
                    description: "Glänzende, hygienische Oberfläche"
                )
            ]

        case .room:
            subscores = [
                Subscore(
                    name: "Ordnung",
                    value: Int((brightness + clarity) / 2 * 100),
                    weight: 0.4,
                    description: "Gegenstände an ihrem Platz"
                ),
                Subscore(
                    name: "Detailgrad",
                    value: Int(clarity * 100),
                    weight: 0.35,
                    description: "Aufmerksamkeit für Details"
                ),
                Subscore(
                    name: "Vollständigkeit",
                    value: Int(uniformity * 100),
                    weight: 0.25,
                    description: "Alle Bereiche wurden aufgeräumt"
                )
            ]
        }

        return subscores
    }

    /// Calculate overall score from subscores
    private func calculateOverallScore(from subscores: [Subscore]) -> Int {
        let weightedSum = subscores.reduce(0.0) { sum, subscore in
            sum + (Double(subscore.value) * subscore.weight)
        }
        return Int(weightedSum.rounded())
    }

    /// Calculate confidence level
    private func calculateConfidence(from subscores: [Subscore], category: ChallengeCategory) -> Double {
        // Simple heuristic: Higher variance in subscores = lower confidence
        let values = subscores.map { Double($0.value) }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        let standardDeviation = sqrt(variance)

        // Lower standard deviation = higher confidence
        // Normalize to 0.0-1.0 range
        let normalizedSD = min(standardDeviation / 50.0, 1.0)
        let baseConfidence = 1.0 - normalizedSD

        // Boost confidence for higher scores
        let scoreBonus = mean > 70 ? 0.1 : 0.0

        return min(max(baseConfidence + scoreBonus, 0.0), 1.0)
    }

    /// Generate explanation text
    private func generateExplanation(
        overallScore: Int,
        subscores: [Subscore],
        category: ChallengeCategory
    ) -> String {
        let scoreLevel: String
        let encouragement: String

        switch overallScore {
        case 0..<50:
            scoreLevel = "noch Verbesserungsbedarf"
            encouragement = "Beim nächsten Mal wird es besser!"
        case 50..<70:
            scoreLevel = "ein gutes Ergebnis"
            encouragement = "Mit etwas mehr Aufmerksamkeit auf Details wird es noch besser."
        case 70..<85:
            scoreLevel = "ein sehr gutes Ergebnis"
            encouragement = "Weiter so!"
        case 85...100:
            scoreLevel = "ein hervorragendes Ergebnis"
            encouragement = "Du bist ein echter Haushalts-Held!"
        default:
            scoreLevel = "ein Ergebnis"
            encouragement = ""
        }

        // Find the lowest subscore for improvement suggestion
        let lowestSubscore = subscores.min(by: { $0.value < $1.value })

        var explanation = "Du hast \(scoreLevel) erzielt. "

        if let lowest = lowestSubscore, lowest.value < 70 {
            explanation += "Achte beim nächsten Mal besonders auf \(lowest.name.lowercased()). "
        }

        explanation += encouragement

        return explanation
    }

    // MARK: - Image Analysis (Heuristic for MVP)

    /// Analyze brightness difference between images
    private func analyzeBrightnessDifference(before: UIImage, after: UIImage) async -> Double {
        let beforeBrightness = await calculateAverageBrightness(image: before)
        let afterBrightness = await calculateAverageBrightness(image: after)

        // Improvement = after is brighter
        let improvement = (afterBrightness - beforeBrightness) / beforeBrightness
        return min(max(0.5 + improvement, 0.0), 1.0)
    }

    /// Analyze image clarity (simplified edge detection proxy)
    private func analyzeClarity(image: UIImage) async -> Double {
        // For MVP: Random-ish value based on image size
        // Future: Use Vision API for actual edge detection
        let pixelCount = (image.size.width * image.size.height) / 1000.0
        let normalizedClarity = min(pixelCount / 5000.0, 1.0)
        return 0.6 + (normalizedClarity * 0.3) // Range: 0.6-0.9
    }

    /// Analyze uniformity across image
    private func analyzeUniformity(image: UIImage) async -> Double {
        // For MVP: Simplified calculation
        // Future: Analyze color/brightness distribution
        return Double.random(in: 0.65...0.95)
    }

    /// Calculate average brightness of an image
    private func calculateAverageBrightness(image: UIImage) async -> Double {
        guard let cgImage = image.cgImage else { return 0.5 }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return 0.5
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelData = context.data else { return 0.5 }

        let pixels = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
        var totalBrightness: UInt64 = 0

        for i in 0..<(width * height) {
            totalBrightness += UInt64(pixels[i])
        }

        return Double(totalBrightness) / Double(width * height * 255)
    }

    /// Generate heatmap data (simplified for MVP)
    private func generateHeatmap(
        beforeImage: UIImage,
        afterImage: UIImage
    ) async -> HeatmapData? {
        // For MVP: Create a simple grid-based heatmap
        let gridSize = 20

        var intensityMap: [[Double]] = Array(
            repeating: Array(repeating: 0.0, count: gridSize),
            count: gridSize
        )

        // Generate random-ish heatmap for demonstration
        // Future: Calculate actual pixel differences
        for y in 0..<gridSize {
            for x in 0..<gridSize {
                // Center has higher intensity (simulating focus area)
                let centerX = Double(gridSize) / 2.0
                let centerY = Double(gridSize) / 2.0
                let distance = sqrt(pow(Double(x) - centerX, 2) + pow(Double(y) - centerY, 2))
                let maxDistance = sqrt(pow(centerX, 2) + pow(centerY, 2))

                let normalizedDistance = distance / maxDistance
                let intensity = max(0.0, 1.0 - normalizedDistance + Double.random(in: -0.2...0.2))

                intensityMap[y][x] = min(max(intensity, 0.0), 1.0)
            }
        }

        return HeatmapData(
            width: gridSize,
            height: gridSize,
            intensityMap: intensityMap
        )
    }
}
