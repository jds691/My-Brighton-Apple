//
//  Dashboard++.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/03/2026.
//

import Foundation
import DashboardKit
import SwiftData
import SwiftUI
import Router

@Model
class TempEntry: DashboardEntry, NavigableEntry {
    var id: String
    
    @Transient
    var navigationPoint: Navigation = Navigation.modal(.account)

    var creationDate: Date

    var idk: String

    required init() {
        self.id = ""
        self.idk = ""
        self.creationDate = .now
    }
}

struct TempCategory: DashboardKit.Category {
    let id: String = "TEMP"

    let title: LocalizedStringResource = ""

    let description: LocalizedStringResource? = nil

    func content(dashboard: Dashboard, entry: TempEntry) -> some View {
        Text(entry.idk)
    }
}

enum DashboardID: String, CaseIterable {
    case yourUpdates = "inbox"
    case importantUpdates = "important"

    public var dashboard: Dashboard {
        return Dashboard(self.rawValue, categories: self.categories)
    }

    public var categories: [any DashboardKit.Category] {
        switch self {
            case .yourUpdates:
                [TempCategory()]
            case .importantUpdates:
                [TempCategory()]
        }
    }
}
