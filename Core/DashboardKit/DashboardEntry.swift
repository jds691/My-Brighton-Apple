//
//  DashboardEntry.swift
//  My Brighton
//
//  Created by Neo Salmon on 28/03/2026.
//

import Foundation
import SwiftData

public protocol DashboardEntry: AnyObject, PersistentModel {
    var creationDate: Date { get set }

    init()
}
