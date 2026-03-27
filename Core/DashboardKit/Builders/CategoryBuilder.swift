//
//  CategoryBuilder.swift
//  DashboardKit
//
//  Created by Neo Salmon on 27/03/2026.
//

import Foundation

@resultBuilder
public enum CategoryBuilder {
    public static func buildBlock() -> [any Category] {
        return []
    }

    public static func buildExpression(_ expression: any Category) -> [any Category] {
        [expression]
    }

    public static func buildExpression(_ expression: [any Category]) -> [any Category] {
        expression
    }

    public static func buildBlock(_ components: any Category...) -> [any Category] {
        return components
    }

    public static func buildBlock(_ components: [any Category]...) -> [any Category] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[any Category]]) -> [any Category] {
        components.flatMap { $0 }
    }

    public static func buildEither(first components: any Category) -> [any Category] {
        [components]
    }

    public static func buildEither(second components: any Category) -> [any Category] {
        [components]
    }

    public static func buildEither(first components: [any Category]) -> [any Category] {
        components
    }

    public static func buildEither(second components: [any Category]) -> [any Category] {
        components
    }
}

