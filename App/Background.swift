//
//  ContainerBackgroundPlacement++.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/08/2025.
//

import SwiftUI

struct MyBrightonBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        #if os(iOS)
            .containerBackground(.brightonBackground, for: .navigation)
        #else
            .background(.brightonBackground)
        #endif
    }
}

extension View {
    func myBrightonBackground() -> some View {
        self.modifier(MyBrightonBackgroundViewModifier())
    }
}
