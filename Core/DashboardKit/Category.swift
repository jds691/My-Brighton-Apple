//
//  Category.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/03/2026.
//

import Foundation
import SwiftUI

public protocol Category : Identifiable, Sendable {
    associatedtype Entry: DashboardEntry
    associatedtype EntryView: View

    var id: String { get }
    var title: LocalizedStringResource { get }
    var description: LocalizedStringResource? { get }

    @MainActor
    @ViewBuilder
    var content: ((Dashboard, Entry) -> EntryView) { get }
}
