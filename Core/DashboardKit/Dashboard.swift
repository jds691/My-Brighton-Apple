//
//  Dashboard.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
public final class Dashboard: Identifiable {
    private let entryTypes: [any DashboardEntry.Type]
    let categories: [any Category]
    var modelContext: ModelContext?

    public let id: String

    private var _entries: [any DashboardEntry]
    public var entries: [any DashboardEntry] {
        get {
            if _entries.isEmpty {
                do {
                    try fillEntries()
                } catch {
                    // TODO: Log
                }
            }

            return _entries
        }
    }

    private var _fetchLimit: Int? = nil
    public var fetchLimit: Int? {
        get { return _fetchLimit }
        set {
            _fetchLimit = newValue

            do {
                try fillEntries()
            } catch {
                // TODO: Log
            }
        }
    }

    public init(_ id: String, categories: [any Category]) {
        self.id = id
        self.categories = categories
        self._entries = []
        self.modelContext = nil

        self.entryTypes = self.categories.map { DashboardService.extractEntryType(from: $0) }
    }

    func storeEntry(_ entry: some DashboardEntry) throws (DashboardError) {
        guard let modelContext else { throw .invalidInternalConfiguration }

        var targetCategory: (any Category)? = nil
        for category in categories {
            if canCategoryHandleEntry(category, entry) {
                targetCategory = category
                break
            }
        }

        guard targetCategory != nil else { throw .noValidCategory }

        entry.creationDate = .now
        modelContext.insert(entry)

        do {
            try modelContext.save()
        } catch {
            throw .saveFailed
        }

        do {
            try fillEntries()
        } catch {
            // TODO: Log
        }
    }

    func getCategory<E: DashboardEntry>(for entry: E) -> (any Category)? {
        categories.first(where: { DashboardService.extractEntryType(from: $0).self === E.self })
    }

    private func fillEntries() throws (DashboardError) {
        var entries: [any DashboardEntry] = []

        for entryType in entryTypes {
            try entries.append(contentsOf: getEntries(for: entryType))
        }

        entries
            .sort(by: { lhs, rhs in
                if lhs.creationDate != rhs.creationDate {
                    return lhs.creationDate > rhs.creationDate
                } else {
                    return getEntryTypeIndex(for: lhs) < getEntryTypeIndex(for: rhs)
                }
            })

        if let fetchLimit {
            _entries = Array(entries.prefix(fetchLimit))
        } else {
            _entries = entries
        }
    }

    private func getEntries<E: DashboardEntry>(for type: E.Type) throws (DashboardError) -> [E] {
        guard let modelContext else { throw .invalidInternalConfiguration }

        var fetchRequest = FetchDescriptor<E>()
        fetchRequest.fetchLimit = fetchLimit

        do {
            return try modelContext.fetch(fetchRequest)
        } catch {
            throw .fetchFailed
        }
    }

    private func getEntryTypeIndex<E: DashboardEntry>(for type: E) -> Int {
        entryTypes.firstIndex(where: { $0.self === E.self }) ?? 0
    }

    private func canCategoryHandleEntry<C: Category, E: DashboardEntry>(_ category: C, _ entry: E) -> Bool {
        return C.Entry.self === E.self
    }
}
