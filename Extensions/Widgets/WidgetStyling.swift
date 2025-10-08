//
//  WidgetBackground.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/09/2025.
//

import SwiftUI
import WidgetKit

struct WidgetBorderViewModifier: ViewModifier {
    @Environment(\.showsWidgetContainerBackground) private var isShowingBackground

    func body(content: Content) -> some View {
        content
            .overlay {
                if isShowingBackground {
                    ContainerRelativeShape()
                        .strokeBorder(lineWidth: 3, antialiased: true)
                }
            }
    }
}

extension View {
    func widgetBorder() -> some View {
        modifier(WidgetBorderViewModifier())
    }

    func widgetBackground() -> some View {
        containerBackground(for: .widget) {
            Rectangle()
                .foregroundStyle(.brightonBackground)
        }
    }
}
