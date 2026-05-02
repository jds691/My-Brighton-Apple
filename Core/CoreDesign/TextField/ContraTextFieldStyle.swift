//
//  ContraTextFieldStyle.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI

public struct ContraTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(.brightonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
            .containerShape(RoundedRectangle(cornerRadius: 16, style: .circular))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .strokeBorder(lineWidth: 3, antialiased: true)
            }
    }
}

extension TextFieldStyle where Self == ContraTextFieldStyle {
    public static var contra: ContraTextFieldStyle {
        ContraTextFieldStyle()
    }
}
