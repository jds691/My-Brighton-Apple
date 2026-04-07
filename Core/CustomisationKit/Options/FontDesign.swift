//
//  FontStyle.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftUI

public enum FontDesign: String, RawRepresentable, Codable {
    case regular = "regular"
    case rounded = "rounded"
    case serif = "serif"
    case monospace = "monospace"

    public func swiftUIFont(_ style: Font.TextStyle) -> Font {
        switch self {
            case .regular:
                    .system(style)
            case .rounded:
                    .system(style, design: .rounded)
            case .serif:
                    .system(style, design: .serif)
            case .monospace:
                    .system(style, design: .monospaced)
        }
    }
}
