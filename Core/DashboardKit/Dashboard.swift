//
//  Dashboard.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

import Foundation
import Observation
import SwiftData

public typealias DashboardEntry = Identifiable & PersistentModel & Hashable

@Observable
public final class Dashboard: Identifiable {
    public let id: String
    let categories: [any Category]

    public private(set) var entries: [any DashboardEntry]

    public var fetchLimit: Int = 10

    public init(_ id: String, categories: [any Category]) {
        self.id = id
        self.categories = categories
        self.entries = []
    }

    func storeEntry(_ entry: some DashboardEntry, with modelContext: ModelContext) throws (DashboardError) {
        var targetCategory: (any Category)? = nil
        for category in categories {
            if canCategoryHandleEntry(category, entry) {
                targetCategory = category
                break
            }
        }

        guard targetCategory != nil else { throw .noValidCategory }

        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            throw .saveFailed
        }

        // TODO: Refresh the entries property
    }

    private func canCategoryHandleEntry<C: Category, E: DashboardEntry>(_ category: C, _ entry: E) -> Bool {
        return C.Entry.self === E.self
    }
}
