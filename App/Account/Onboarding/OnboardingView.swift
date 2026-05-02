//
//  OnboardingView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import LearnKit
import CustomisationKit

struct OnboardingView: View {
    @Environment(\.learnKitService) private var learnKit

    @Binding var canShowContentView: Bool

    @State private var displayedScreen: DisplayedScreen = .welcome

    @available(macOS 15.0, *)
    init() {
        self._canShowContentView = .constant(false)
    }

    @available(iOS 18.0, *)
    init(canShowContentView: Binding<Bool>?) {
        if let canShowContentView {
            self._canShowContentView = canShowContentView
        } else {
            self._canShowContentView = .constant(false)
        }
    }

    var body: some View {
        NavigationStack {
            switch displayedScreen {
                case .welcome:
                    OnboardingWelcomeView(displayedScreen: $displayedScreen)
                        .transition(.slide)
                case .signIn:
                    OnboardingSignInView(displayedScreen: $displayedScreen)
                        .transition(.slide)
                case .customise:
                    OnboardingCustomiseView(displayContentView: $canShowContentView)
                        .transition(.slide)
            }
        }
        .onAppear {
            displayedScreen = .welcome
        }
        .task {
            do {
                try await CustomisationService.shared.eraseAll()
            } catch {
                fatalError()
            }

            do {
                try await learnKit.eraseAllCache()
            } catch {
                fatalError("LearnKit could not be erased. Unable to safely continue!")
            }

            MyBrightonAppShortcuts.updateAppShortcutParameters()
        }
    }

    enum DisplayedScreen: Hashable {
        case welcome
        case signIn
        case customise
    }
}

#Preview(traits: .unauthenticatedAccount) {
    OnboardingView()
}
