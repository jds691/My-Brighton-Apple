//
//  Color+Codable.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftUI

struct CodableColor: Codable {
    let red: Float
    let green: Float
    let blue: Float

    var color: Color {
        Color(red: Double(red), green: Double(green), blue: Double(blue))
    }

    static func fromColor(_ color: Color) -> CodableColor {
        let resolved = color.resolve(in: EnvironmentValues())
        return CodableColor(
            red: resolved.red,
            green: resolved.green,
            blue: resolved.blue
        )
    }
}


extension Color: @retroactive Codable {
    public init(from decoder: any Decoder) throws {
        self = try CodableColor(from: decoder).color
    }
    
    public func encode(to encoder: any Encoder) throws {
        try CodableColor.fromColor(self).encode(to: encoder)
    }
}
