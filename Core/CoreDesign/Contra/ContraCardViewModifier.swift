//
//  ContraCardViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 26/04/2026.
//

import SwiftUI

struct ContraCardViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.brightonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
            .containerShape(RoundedRectangle(cornerRadius: 16, style: .circular))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .strokeBorder(lineWidth: 3, antialiased: true)
            }
    }
}

extension View {
    public func contraCard() -> some View {
        modifier(ContraCardViewModifier())
    }
}
