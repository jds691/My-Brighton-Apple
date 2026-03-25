//
//  DashboardService.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

public final class DashboardService: Sendable {
    private let dashboards: [Dashboard]

    public init(dashboards: [Dashboard]) {
        self.dashboards = dashboards
    }

    public func getDashboard(for id: Dashboard.ID) -> Dashboard? {
        return dashboards.first(where: { $0.id == id })
    }

    public func postEntry<Entry: DashboardEntry>(_ entry: Entry, to dashboard: Dashboard.ID) throws (DashboardError) {
        // TODO: Implement
    }
}
