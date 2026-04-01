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

    var creationDate: Date { get set }

    init()
}
