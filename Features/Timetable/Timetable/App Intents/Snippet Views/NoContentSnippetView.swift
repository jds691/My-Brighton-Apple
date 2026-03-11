//
//  NoContentSnippedView.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/10/2025.
//

import SwiftUI
import CoreDesign

struct NoContentSnippetView<Label: View>: View {
    private var label: Label

    init(_ text: LocalizedStringResource) where Label == Text {
        self.label = Text(text)
    }

    init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label()
    }

    var body: some View {
        NoContentView {
            label
        }
        .frame(minHeight: 80)
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .cornerRadiusStyle(.containerRelative)
                    .background(.brightonBackground)

                    //.scenePadding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.brightonBackground)
                    .scenePadding([.horizontal, .top])
                    .foregroundStyle(.primary, .brightonSecondary)
            } else {
                $0
                    .cornerRadiusStyle(.rounded(cornerRadius: 16))
                    .background(.brightonBackground)

                    .scenePadding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
