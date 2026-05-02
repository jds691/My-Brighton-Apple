//
//  ContraTextFieldStyle.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI

public struct UnderlinedTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        #if os(macOS)
        configuration
        #else
        configuration
            .padding(.vertical, 8)
            .background(
                VStack {
                    Spacer()
                    Color(.brightonSecondary)
                        .clipShape(Capsule())
                        .frame(height: 2)
                }
            )
        #endif
    }
}

extension TextFieldStyle where Self == UnderlinedTextFieldStyle {
    public static var underlined: UnderlinedTextFieldStyle {
        UnderlinedTextFieldStyle()
    }
}
