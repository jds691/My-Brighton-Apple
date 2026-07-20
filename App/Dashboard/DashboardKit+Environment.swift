//
//  DashboardKit+Environment.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/03/2026.
//

import SwiftUI
import DashboardKit

private let defaultService: DashboardService = DashboardService(dashboards: DashboardID.allCases.map(\.dashboard))

extension EnvironmentValues {
    @Entry var dashboardService: DashboardService = defaultService
}
