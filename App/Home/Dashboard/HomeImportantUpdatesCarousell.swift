//
//  HomeImportantUpdatesCarousell.swift
//  My Brighton
//
//  Created by Neo Salmon on 05/04/2026.
//

import Foundation
import simd
import SwiftUI
import DashboardKit
import CustomisationKit

struct HomeImportantUpdatesCarousell: View {
    @Environment(\.self) private var environment
    @Environment(\.colorScheme) private var colorScheme

    @State private var backgroundLuminance: Float = -1.0
    @State private var fadeColour: Color = .black

    var dashboard: Dashboard
    var customisations: HomeCustomisation

    var body: some View {
        VStack(alignment: .leading) {
            Text("Important Updates")
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)
            //.padding([.top], 30.0)

            DashboardCarousell(for: dashboard)
                .cardBackgroundStyle(.clear)
                .padding(.bottom, 30)
                .padding(.horizontal, -16)
            // TODO: Isn't applied when NoContentView is showing
                .contentMargins(.horizontal, 16, for: .scrollContent)
        }
        .environment(\.colorScheme, clearColorScheme)
        .padding(.horizontal, 16)
        .background {
            background
                .modifierBranch {
                    if #available(iOS 26, macOS 26, *) {
                        $0
                            .backgroundExtensionEffect()
                    } else {
                        $0
                    }
                }
        }
        .onAppear {
            fadeColour = customisations.background.avgColor(for: environment)
            backgroundLuminance = customisations.background.calculateLuminance(for: environment)
            print(backgroundLuminance)
        }
        .onChange(of: customisations.background) {
            fadeColour = customisations.background.avgColor(for: environment)
            backgroundLuminance = customisations.background.calculateLuminance(for: environment)
            print(backgroundLuminance)
        }
    }

    @ViewBuilder
    private var background: some View {
        ZStack {
            CustomisedBackgroundView(customisations.background)
                .scaleEffect(CGSize(width: 1.0, height: -1.0))
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                .clipped()
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            CustomisedBackgroundView(customisations.background)
                .scaleEffect(CGSize(width: 1.0, height: -1.0))
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                .clipped()
                .blur(radius: 16)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 0.97)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .padding([.horizontal, .top], -5)
                }
            CustomisedBackgroundView(customisations.background)
                .scaleEffect(CGSize(width: 1.0, height: -1.0))
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                .clipped()
                .blur(radius: 32)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 0.97)
                            ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                        .blur(radius: 5)
                        .padding([.horizontal, .top], -5)
                }

            fadeColour
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                .clipped()
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .drawingGroup()
    }

    private var clearColorScheme: ColorScheme {
        if backgroundLuminance == -1.0 { return colorScheme }

        if backgroundLuminance <= 50.0 {
            return .dark
        } else {
            return .light
        }
    }
}
