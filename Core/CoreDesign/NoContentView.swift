//
//  NoContentView.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/08/2025.
//

import SwiftUI
import WidgetKit

public struct NoContentView<Label: View>: View {
    @Environment(\.widgetContentMargins) private var margins
    @Environment(\.showsWidgetContainerBackground) private var hasBackground

    private var label: Label

    private var radiiStyle: CornerRadiusStyle = .rounded(cornerRadius: 16)

    public init(_ text: LocalizedStringResource) where Label == Text {
        self.label = Text(text)
    }

    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label()
    }

    public var body: some View {
        ZStack {
            label
                .padding(margins)
            switch radiiStyle {
                case .rounded(let cornerRadius):
                    RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [6, 6]), antialiased: true)
                case .containerRelative:
                    ContainerRelativeShape()
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [6, 6]), antialiased: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundStyle(hasBackground ? .brightonSecondary : .primary)
        .modifierBranch {
            switch radiiStyle {
                case .rounded(let cornerRadius):
                    $0
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .circular))
                case .containerRelative:
                    $0
                        .clipShape(ContainerRelativeShape())
            }
        }
    }

    public enum CornerRadiusStyle {
        case rounded(cornerRadius: CGFloat)
        case containerRelative
    }
}

extension NoContentView {
    public func cornerRadiusStyle(_ style: CornerRadiusStyle) -> Self {
        var view = self
        view.radiiStyle = style

        return view
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NoContentView("No Recent Discussions")
}
