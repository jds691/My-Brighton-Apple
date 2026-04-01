//
//  Color+Codable.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftUI

public struct CodableColor: Codable {
    let red: Float
    let green: Float
    let blue: Float

    public var resolved: Color {
        Color(red: Double(red), green: Double(green), blue: Double(blue))
    }

    public static func fromColor(_ color: Color) -> CodableColor {
        let resolved = color.resolve(in: EnvironmentValues())
        return CodableColor(
            red: resolved.red,
            green: resolved.green,
            blue: resolved.blue
        )
    }
}
