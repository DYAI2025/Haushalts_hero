//
//  MainView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI

/// Main view that orchestrates the entire app flow
struct MainView: View {

    // MARK: - Properties

    @EnvironmentObject var container: AppContainer

    // MARK: - Body

    var body: some View {
        MainContentView(repository: container.repository)
    }
}

/// Internal content view that holds the state
private struct MainContentView: View {
    @StateObject private var challengeViewModel: ChallengeViewModel

    init(repository: AppRepository) {
        _challengeViewModel = StateObject(wrappedValue: ChallengeViewModel(repository: repository))
    }

    var body: some View {
        Group {
            switch challengeViewModel.flowState {
            case .categorySelection:
                ChallengeStartView(viewModel: challengeViewModel)

            case .beforePhoto, .afterPhoto:
                CameraFlowView(viewModel: challengeViewModel)

            case .processing, .result:
                ScoreResultView(viewModel: challengeViewModel)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(AppContainer())
}
