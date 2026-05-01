//
//  OnboardingSignInView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import CoreDesign
import Accounts

struct OnboardingSignInView: View {
    @Environment(\.accountService) private var accountService

    @Binding var displayedScreen: OnboardingView.DisplayedScreen

    @State private var username: String = ""
    @State private var password: String = ""

    @State private var isAttemptingSignIn: Bool = false

    @State private var showError: Bool = false
    @State private var lastError: LocalizedError? = nil

    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username, prompt: Text("Username"))
                .textFieldStyle(.contra)
            SecureField("Password", text: $password, prompt: Text("Password"))
                .textFieldStyle(.contra)

#if os(macOS)
            if #available(macOS 26, *) {
                Button {
                    authenticate()
                } label: {
                    Text("Sign In")
                        .padding(8)
                }
                .buttonStyle(.glassProminent)
                .disabled(isAttemptingSignIn)
                .keyboardShortcut(.defaultAction)
            } else {
                Button {
                    authenticate()
                } label: {
                    Text("Sign In")
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAttemptingSignIn)
                .keyboardShortcut(.defaultAction)
            }

#endif
        }
        .navigationTitle("Sign In")
#if os(iOS)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .navigationBarTitleDisplayMode(.inline)
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .safeAreaBar(edge: .bottom) {
                        Button {
                            authenticate()
                        } label: {
                            Text("Sign In")
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(isAttemptingSignIn)
                        .keyboardShortcut(.defaultAction)
                    }
            } else {
                $0
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            authenticate()
                        } label: {
                            Text("Sign In")
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAttemptingSignIn)
                        .keyboardShortcut(.defaultAction)
                    }
            }
        }
#endif
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK") {
                lastError = nil
            }
        } message: {
            if let errorText = lastError?.errorDescription  {
                Text(errorText)
            } else {
                Text("An unknown error has occurred.")
            }
        }
        .scenePadding()
    }

    private func authenticate() {
        Task {
            isAttemptingSignIn = true

            do {
                try await accountService.signIn(username: username, password: password)

                withAnimation {
                    displayedScreen = .customise
                }
            } catch {
                if let localizedError = error as? LocalizedError {
                    lastError = localizedError
                }

                showError = true
            }

            isAttemptingSignIn = false
        }
    }
}
