//
//  TextAlignment.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftUI

public enum TextAlignment: String, RawRepresentable, Codable {
    case top            = "top"
    case topLeading     = "top leading"
    case topTrailing    = "top trailing"

    case center         = "center"
    case centerLeading  = "center leading"
    case centerTrailing = "center trailing"

    case bottom         = "bottom"
    case bottomLeading  = "bottom leading"
    case bottomTrailing = "bottom trailing"

    public var swiftUIAlignment: Alignment {
        switch self {
            case .top:
                    .top
            case .topLeading:
                    .topLeading
            case .topTrailing:
                    .topTrailing
            case .center:
                    .center
            case .centerLeading:
                    .leading
            case .centerTrailing:
                    .trailing
            case .bottom:
                    .bottom
            case .bottomLeading:
                    .bottomLeading
            case .bottomTrailing:
                    .bottomTrailing
        }
    }
}
