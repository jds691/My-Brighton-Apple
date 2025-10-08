//
//  HeaderBlur.swift
//  My Brighton
//
//  Created by Neo Salmon on 02/09/2025.
//

import SwiftUI

struct HeaderBlurViewModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var shouldReduceTransparency

    func body(content: Content) -> some View {
        content
            .mask {
                if !shouldReduceTransparency {
                    LinearGradient(colors: [.black, .clear], startPoint: UnitPoint(x: 0, y: 0.90), endPoint: UnitPoint(x: 0, y: 0.97))
                        .blur(radius: 5)
                        .padding([.horizontal, .top], -5)
                } else {
                    Color.black
                }
            }
    }
}

public extension View {
    func headerBlur() -> some View {
        modifier(HeaderBlurViewModifier())
    }
}
