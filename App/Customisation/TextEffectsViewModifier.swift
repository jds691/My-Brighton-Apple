//
//  TextEffectsViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/04/2026.
//

import SwiftUI
import CustomisationKit

struct TextEffectsViewModifier: ViewModifier {
    private let effects: TextEffects

    init(_ effects: TextEffects) {
        self.effects = effects
    }

    func body(content: Content) -> some View {
        if effects.contains(.dropShadow) {
            content
                .bold(effects.contains(.bold))
                .italic(effects.contains(.italics))
                .underline(effects.contains(.underline))
                .strikethrough(effects.contains(.strikethrough))
                .shadow(color: .black, radius: 9.3)
        } else {
            content
                .bold(effects.contains(.bold))
                .italic(effects.contains(.italics))
                .underline(effects.contains(.underline))
                .strikethrough(effects.contains(.strikethrough))
        }
    }
}
