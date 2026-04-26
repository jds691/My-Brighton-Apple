//
//  DashboardCarousellCardBackgroundModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import SwiftUI
import CoreDesign

struct DashboardCarousellCardBackgroundModifier: ViewModifier {
    let style: DashboardCarousell.BackgroundCardStyle

    init(_ style: DashboardCarousell.BackgroundCardStyle) {
        self.style = style
    }

    func body(content: Content) -> some View {
        switch style {
            case .standard:
                content
                    .padding(16)
                    .contraCard()
            case .clear:
                if #available(iOS 26, macOS 26, *) {
                    content
                        .padding(16)
                        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16, style: .circular))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .circular)
                                .strokeBorder(lineWidth: 3, antialiased: true)
                        }
                } else {
                    content
                        .padding(16)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .circular)
                                .strokeBorder(lineWidth: 3, antialiased: true)
                        }
                }

        }
    }
}
