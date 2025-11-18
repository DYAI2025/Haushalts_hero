//
//  UserSettings.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import Foundation

/// User settings and preferences
struct UserSettings: Codable, Equatable {
    var enableHapticFeedback: Bool
    var enableSoundEffects: Bool
    var showHeatmapByDefault: Bool
    var notificationsEnabled: Bool
    var selectedAvatar: String?
    var userName: String?
    var onboardingCompleted: Bool

    init(
        enableHapticFeedback: Bool = true,
        enableSoundEffects: Bool = true,
        showHeatmapByDefault: Bool = false,
        notificationsEnabled: Bool = false,
        selectedAvatar: String? = nil,
        userName: String? = nil,
        onboardingCompleted: Bool = false
    ) {
        self.enableHapticFeedback = enableHapticFeedback
        self.enableSoundEffects = enableSoundEffects
        self.showHeatmapByDefault = showHeatmapByDefault
        self.notificationsEnabled = notificationsEnabled
        self.selectedAvatar = selectedAvatar
        self.userName = userName
        self.onboardingCompleted = onboardingCompleted
    }

    /// Default settings for new users
    static let `default` = UserSettings()
}
