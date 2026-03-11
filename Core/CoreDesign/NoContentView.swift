//
//  NoContentView.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/08/2025.
//

import SwiftUI

public struct NoContentView<Label: View>: View {
    private var label: Label

    public init(_ text: LocalizedStringResource) where Label == Text {
        self.label = Text(text)
    }

    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label()
    }

    public var body: some View {
        label
            .frame(maxWidth: .infinity, alignment: .center)
            .scenePadding()
            .frame(minHeight: 80)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [6, 6]), antialiased: true)
            }
            .foregroundStyle(.brightonSecondary)
            .background(.brightonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NoContentView("No Recent Discussions")
}
