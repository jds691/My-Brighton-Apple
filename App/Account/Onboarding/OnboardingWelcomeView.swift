//
//  OnboardingWelcomeView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import CoreDesign

struct OnboardingWelcomeView: View {
    @Binding var displayedScreen: OnboardingView.DisplayedScreen
    
    var body: some View {
        VStack(spacing: 16) {
            Image("Logo-Launch")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: 128.0, height: 128.0)

            Text("Welcome to Project Demo")
                .font(.largeTitle.bold())

            Text("""
                This is a vertical slice of potential improvements that can be made to the online student learning experience.
                
                The demo features working home, Blackboard and search areas. Alongside system integrations.
                
                To begin you’ll be taken though a sign-in flow.
                
                **The sign-in screen is for demo purposes only and does not perform actual authentication.**
                """)
#if os(macOS)
            .frame(maxWidth: 300)
            .fixedSize(horizontal: false, vertical: true)
#endif

#if os(macOS)
            if #available(macOS 26, *) {
                Button {
                    withAnimation {
                        displayedScreen = .signIn
                    }
                } label: {
                    Text("Continue")
                        .padding(8)
                }
                .buttonStyle(.glassProminent)
                .keyboardShortcut(.defaultAction)
            } else {
                Button {
                    withAnimation {
                        displayedScreen = .signIn
                    }
                } label: {
                    Text("Continue")
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }

#endif
        }
        .navigationTitle("Welcome")
#if os(iOS)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .navigationBarTitleDisplayMode(.inline)
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .safeAreaBar(edge: .bottom) {
                        Button {
                            withAnimation {
                                displayedScreen = .signIn
                            }
                        } label: {
                            Text("Continue")
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.glassProminent)
                        .keyboardShortcut(.defaultAction)
                    }
            } else {
                $0
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            withAnimation {
                                displayedScreen = .signIn
                            }
                        } label: {
                            Text("Continue")
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                    }
            }
        }
#endif
        .scenePadding()
    }
}

#Preview(traits: .unauthenticatedAccount) {
    NavigationStack {
        OnboardingWelcomeView(displayedScreen: .constant(.welcome))
    }
}
