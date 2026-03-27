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

    public static func buildBlock(_ components: any Category...) -> [any Category] {
        return components
    }
}

