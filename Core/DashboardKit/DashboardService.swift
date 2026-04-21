//
//  DashboardService.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

import Foundation
import SwiftData

public final class DashboardService {
    private let dashboards: [Dashboard]
    private let inMemory: Bool

    public init(inMemory: Bool = false, dashboards: [Dashboard]) {
        self.inMemory = inMemory
        self.dashboards = dashboards

        for dashboard in dashboards {
            dashboard.initialiseModelContainer(inMemory: inMemory)
        }
    }

    public func getDashboard(for id: Dashboard.ID) -> Dashboard? {
        return dashboards.first(where: { $0.id == id })
    }

    public func postEntry<Entry: DashboardEntry>(_ entry: Entry, to dashboardId: Dashboard.ID) throws (DashboardError) {
        guard let dashboard = dashboards.first(where: { $0.id == dashboardId }) else { throw .dashboardDoesNotExist }

        try dashboard.storeEntry(entry)
    }

    public func deleteEntry<E: DashboardEntry>(by id: String, for type: E.Type, within dashboardId: Dashboard.ID) throws (DashboardError) {
        guard let dashboard = dashboards.first(where: { $0.id == dashboardId }) else { throw .dashboardDoesNotExist }

        try dashboard.deleteEntry(by: id, for: type)
    }

    public func changeEntry<E: DashboardEntry>(with id: String, within dashboardId: Dashboard.ID, updates: @escaping (E) -> Void) throws (DashboardError) {
        guard let dashboard = dashboards.first(where: { $0.id == dashboardId }) else { throw .dashboardDoesNotExist }

        try dashboard.changeEntry(with: id, updates: updates)
    }

    public func eraseContent() throws (DashboardError) {
        for dashboard in dashboards {
            try dashboard.eraseModelContainer()
            dashboard.initialiseModelContainer(inMemory: self.inMemory)
        }
    }

    static func extractEntryType<C: Category>(from category: C) -> any DashboardEntry.Type {
        return C.Entry.self
    }
}
