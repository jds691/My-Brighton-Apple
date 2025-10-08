//
//  ModifierBranch.swift
//  My Brighton
//
//  Created by Neo Salmon on 07/07/2025.
//

import SwiftUI

struct ModifierBranchViewModifier<Result: View>: ViewModifier {
    let modifiers: (Content) -> Result

    init(modifiers: @escaping (Content) -> Result) {
        self.modifiers = modifiers
    }

    func body(content: Content) -> Result {
        modifiers(content)
    }
}

public extension View {
    func modifierBranch(@ViewBuilder _ modifiers: @escaping (Self) -> some View) -> some View {
        //modifier(ModifierBranchViewModifier(modifiers: modifiers))
        modifiers(self)
    }
}
