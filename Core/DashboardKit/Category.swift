//
//  Category.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/03/2026.
//

import Foundation
import SwiftUI
import SwiftData

public protocol Category<Entry, EntryView> : Identifiable {
    associatedtype Entry: DashboardEntry
    associatedtype EntryView: View

    var id: String { get }
    var title: LocalizedStringResource { get }
    var description: LocalizedStringResource? { get }

    @MainActor
    @ViewBuilder
    func content(dashboard: Dashboard, entry: Entry) -> EntryView
}
