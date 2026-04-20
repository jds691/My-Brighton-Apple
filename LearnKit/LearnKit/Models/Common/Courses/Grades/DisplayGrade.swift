//
//  DisplayGrade.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/04/2026.
//

import Foundation

public struct DisplayGrade: Hashable, Sendable {
    public let scale: ScaleType
    public let score: Double?
    public let text: String?

    init?(from displayGradeSchema: Components.Schemas.DisplayGrade) {
        guard let scale = displayGradeSchema.scaleType else { return nil }

        self.scale = ScaleType(from: scale)
        self.score = displayGradeSchema.score
        self.text = displayGradeSchema.text
    }

    public enum ScaleType: Hashable, Sendable {
        case percent
        case score
        case tabular
        case text

        init(from displayGradeScaleTypeSchema: Components.Schemas.DisplayGrade.ScaleTypePayload) {
            switch displayGradeScaleTypeSchema {
                case .percent:
                    self = .percent
                case .score:
                    self = .score
                case .tabular:
                    self = .tabular
                case .text:
                    self = .text
            }
        }
    }
}
