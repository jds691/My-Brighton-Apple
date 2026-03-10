//
//  NoContentSnippedView.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/10/2025.
//

import SwiftUI

struct NoContentSnippetView<Label: View>: View {
    private var label: Label

    init(_ text: LocalizedStringResource) where Label == Text {
        self.label = Text(text)
    }

    init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label()
    }

    var body: some View {
        label
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(minHeight: 81)
            .scenePadding()

            .modifierBranch {
                if #available(iOS 26, macOS 26, *) {
                    $0
                        .overlay {
                            ContainerRelativeShape()
                                .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [6, 6]), antialiased: true)
                        }
                        .foregroundStyle(.brightonSecondary)
                        .background(.brightonBackground)
                        .clipShape(ContainerRelativeShape())

                        //.scenePadding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.brightonBackground)
                        .clipShape(ContainerRelativeShape())
                        .scenePadding([.horizontal, .top])
                        .foregroundStyle(.primary, .brightonSecondary)
                } else {
                    $0
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .circular)
                                .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [6, 6]), antialiased: true)
                        }
                        .foregroundStyle(.brightonSecondary)
                        .background(.brightonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))

                        .scenePadding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
    }
}
