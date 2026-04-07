//
//  TextEffects.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/04/2026.
//

import Foundation

public struct TextEffects: OptionSet, Codable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let bold = TextEffects(rawValue: 1 << 0)
    public static let italics = TextEffects(rawValue: 1 << 1)
    public static let underline = TextEffects(rawValue: 1 << 2)
    public static let strikethrough = TextEffects(rawValue: 1 << 3)

    public static let dropShadow = TextEffects(rawValue: 1 << 4)
}
