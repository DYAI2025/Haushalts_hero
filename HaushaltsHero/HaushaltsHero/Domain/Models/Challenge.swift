//
//  Challenge.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation
import UIKit

/// Represents a cleaning challenge with before/after photos and scoring
struct Challenge: Identifiable, Codable {
    let id: UUID
    let category: ChallengeCategory
    let beforePhotoPath: String  // Local file path
    let afterPhotoPath: String   // Local file path
    let timestamp: Date
    var score: ExplainableScore?

    init(
        id: UUID = UUID(),
        category: ChallengeCategory,
        beforePhotoPath: String,
        afterPhotoPath: String,
        timestamp: Date = Date(),
        score: ExplainableScore? = nil
    ) {
        self.id = id
        self.category = category
        self.beforePhotoPath = beforePhotoPath
        self.afterPhotoPath = afterPhotoPath
        self.timestamp = timestamp
        self.score = score
    }
}

/// Challenge categories matching the MVP scope
enum ChallengeCategory: String, CaseIterable, Codable {
    case mirror = "Spiegel"
    case toilet = "Toilette"
    case room = "Zimmer"

    var icon: String {
        switch self {
        case .mirror: return "mirror"
        case .toilet: return "toilet.circle"
        case .room: return "bed.double"
        }
    }

    var description: String {
        return self.rawValue
    }
}
