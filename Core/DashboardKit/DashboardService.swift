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

    // Copied from LearnKit
    private let modelExecutor: any ModelExecutor
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }

    public init(inMemory: Bool = false, dashboards: [Dashboard]) {
        self.dashboards = dashboards

        var entryTypes: [any PersistentModel.Type] = []
        for categories in self.dashboards.map(\.categories) {
            for category in categories {
                entryTypes.append(DashboardService.extractEntryType(from: category))
            }
        }

        do {
            let schemaV1: Schema = .init(entryTypes)

            let config: ModelConfiguration = .init("Dashboard", schema: schemaV1, isStoredInMemoryOnly: inMemory, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))

            for dashboard in dashboards {
                dashboard.modelContext = modelContext
            }
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

    public func getDashboard(for id: Dashboard.ID) -> Dashboard? {
        return dashboards.first(where: { $0.id == id })
    }

    public func postEntry<Entry: DashboardEntry>(_ entry: Entry, to dashboardId: Dashboard.ID) throws (DashboardError) {
        guard let dashboard = dashboards.first(where: { $0.id == dashboardId }) else { throw .dashboardDoesNotExist }

        try dashboard.storeEntry(entry)
    }

    public func debugEraseContent() {
        do {
            try modelContainer.erase()
            exit(0)
        } catch {
            print(error)
        }
    }

    static func extractEntryType<C: Category>(from category: C) -> any DashboardEntry.Type {
        return C.Entry.self
    }
}
