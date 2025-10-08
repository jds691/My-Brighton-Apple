//
//  FloatingButtonStyle.swift
//  My Brighton
//
//  Created by Neo Salmon on 07/08/2025.
//

import SwiftUI

public struct FloatingButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.regularMaterial)
                    .shadow(radius: 1)
            }
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

public extension ButtonStyle where Self == FloatingButtonStyle {
    static var floating: FloatingButtonStyle {
        FloatingButtonStyle()
    }
}
