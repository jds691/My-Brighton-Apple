//
//  HomeHeaderBlurViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 07/04/2026.
//

import SwiftUI
import CustomisationKit

struct HomeHeaderBlurViewModifier: ViewModifier {
    @Environment(\.self) private var environment
    @Environment(\.accessibilityReduceTransparency) private var shouldReduceTransparency

    var customisations: HomeCustomisation
    var opaque: Bool

    @State private var fadeColour: Color = .black

    func body(content: Content) -> some View {
        if opaque && !shouldReduceTransparency {
            ZStack {
                content

                fadeColour
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                    .clipped()
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0.05),
                                .init(color: .clear, location: 0.3)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
            }
            // Means that if this view is redrawn it can just remember the average colour value
            .onAppear {
                fadeColour = customisations.background.avgColor(for: environment)
            }
            .onChange(of: customisations.background) {
                fadeColour = customisations.background.avgColor(for: environment)
            }
        } else {
            content
                .headerBlur()
        }
    }
}

public extension View {
    func homeHeaderBlur(customisations: HomeCustomisation, opaque: Bool = false) -> some View {
        modifier(HomeHeaderBlurViewModifier(customisations: customisations, opaque: opaque))
    }
}
