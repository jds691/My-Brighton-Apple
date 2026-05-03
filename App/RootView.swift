//
//  RootView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import LearnKit
import CustomisationKit
import Timetable

struct RootView: View {
    @Environment(\.accountService) private var accountService
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss

    @Environment(\.timetableService) private var timetableService
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.dashboardService) private var dashboardService
    @Environment(\.notifier) private var notifier
    @AppStorage(TimetableService.remoteURLUserDefaultsKey) private var timetableURL: URL?

    @Environment(\.dismissWindow) private var dismissWindow

    @State private var showAuthErrorAlert: Bool = false

    @State private var canShowContentView: Bool = false

    var body: some View {
        Group {
            if canShowContentView {
                ContentView()
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
            } else {
#if os(iOS)
                OnboardingView(canShowContentView: $canShowContentView)
                    .task {
                        if accountService.authenticationStatus == .authenticated {
                            canShowContentView = true
                        } else {
                                do {
                                    try await Task.sleep(nanoseconds: 1_000_000)
                                } catch {

                                }

                                dismissWindow(id: "module")

                                notifier.removeAllNotifications()

                                timetableURL = nil
                                timetableService.clearCalendarCache()
                                timetableService.setRemoteURL(nil)

                                do {
                                    try dashboardService.eraseContent()

                                } catch {
                                    fatalError()
                                }

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
#else
                VStack {
                    EmptyView()
                }
                .onAppear {
                    if accountService.authenticationStatus == .authenticated {
                        canShowContentView = true
                    } else {
                        openWindow(id: "sign-in")
                        dismiss()
                    }
                }
#endif
            }
        }
    }

    private func showSignIn() {
#if os(macOS)
        openWindow(id: "sign-in")
        dismiss()
#else
        canShowContentView = false
#endif
    }
}
