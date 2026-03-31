//
//  NavigableEntry.swift
//  My Brighton
//
//  Created by Neo Salmon on 31/03/2026.
//

import Router
import SwiftData

public protocol NavigableEntry: DashboardEntry {
    var navigationPoint: Navigation { get }
}
