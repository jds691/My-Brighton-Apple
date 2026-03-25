//
//  DashboardBuilder.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

import Foundation

@resultBuilder
public enum DashboardBuilder {
    public static func buildBlock() -> [Dashboard] {
        return []
    }

    public static func buildBlock(_ components: Dashboard...) -> [Dashboard] {
        return components
    }
}
