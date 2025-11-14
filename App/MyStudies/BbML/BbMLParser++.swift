//
//  BbMLParser++.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/11/2025.
//

import SwiftBbML

extension BbMLParser {
    static var `default`: BbMLParser {
        BbMLParser(
            options: ParserOptions(
                preferredMathFormat: .mathMl
            )
        )
    }
}
