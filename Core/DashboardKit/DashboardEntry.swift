//
//  DashboardEntry.swift
//  My Brighton
//
//  Created by Neo Salmon on 28/03/2026.
//

import Foundation
import SwiftData

public protocol DashboardEntry: AnyObject, Identifiable, PersistentModel {
    var id: String { get set }

    /// Represents the time at which this entry was first inserted.
    ///
    /// This value is set by DashboardKit. Manually set values will be overwritten at insertion.
    var creationDate: Date { get set }

    init()
}
