//
//  DashboardKit+Environment.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/03/2026.
//

import SwiftUI
import DashboardKit

extension EnvironmentValues {
    @Entry var dashboardService: DashboardService = DashboardService(dashboards: DashboardID.allCases.map(\.dashboard))
}
