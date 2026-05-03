//
//  SignInExpiredViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import Accounts

struct SignInExpiredViewModifier: ViewModifier {
    @Environment(\.accountService) private var accountService
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss

    @State private var showAuthErrorAlert: Bool = false

    func body(content: Content) -> some View {
        content
            .task {
                if accountService.authenticationStatus == .signedOut {
                    showSignIn()
                } else if accountService.authenticationStatus != .authenticated {
                    showAuthErrorAlert = true
                }
            }
            .onChange(of: accountService.authenticationStatus) {
                if accountService.authenticationStatus == .signedOut {
                    showSignIn()
                } else if accountService.authenticationStatus != .authenticated {
                    showAuthErrorAlert = true
                }
            }
            .alert("Sign In Error", isPresented: $showAuthErrorAlert) {
                Button("OK") {
                    showSignIn()
                }
            } message: {
                switch accountService.authenticationStatus {
                    case .notAuthenticated:
                        Text("You must be signed in to use Project Demo.")
                    case .authenticationExpired:
                        Text("This session has expired. You must sign back in.")
                    case .authenticated, .signedOut:
                        Text("An unknown error has occurred.")
                }
            }
    }

    private func showSignIn() {
#if os(macOS)
        openWindow(id: "sign-in")
#endif
        dismiss()
    }
}
