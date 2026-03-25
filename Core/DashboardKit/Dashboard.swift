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
    private let inMemory: Bool
    private let categories: [any Category]

    public private(set) var entries: [any DashboardEntry]

    public var fetchLimit: Int = 10

    public init(id: String, inMemory: Bool = false, categories: [any Category]) {
        self.id = id
        self.inMemory = inMemory
        self.categories = categories
        self.entries = []
    }
}
