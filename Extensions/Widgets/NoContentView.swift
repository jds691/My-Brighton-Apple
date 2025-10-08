//
//  NoContentView.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/08/2025.
//

import SwiftUI

// TODO: De-duplicate and move into a common framework
public struct NoContentView<Label: View>: View {
    @Environment(\.widgetContentMargins) private var margins
    @Environment(\.showsWidgetContainerBackground) private var hasBackground

    private var label: Label

    public init(_ text: LocalizedStringResource) where Label == Text {
        self.label = Text(text)
    }

    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label()
    }

    public var body: some View {
        label
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(margins)
            .overlay {
                ContainerRelativeShape()
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [6, 6]), antialiased: true)
            }
            .foregroundStyle(hasBackground ? .brightonSecondary : .primary)
            .clipShape(ContainerRelativeShape())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NoContentView("No Recent Discussions")
}
