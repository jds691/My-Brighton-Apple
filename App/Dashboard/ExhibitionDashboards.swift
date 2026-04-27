//
//  ExhibitionDashboards.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/04/2026.
//

import DashboardKit
import SwiftData
import SwiftUI
import Router

@Model
class ExhibitionWelcomeEntry: DashboardEntry {
    var dashboardId: DashboardKit.Dashboard.ID

    var id: String
    var creationDate: Date

    var title: String
    var text: String

    required init() {
        self.dashboardId = ""
        self.id = "WELCOME_MESSAGE"
        self.title = ""
        self.text = ""
        self.creationDate = .now
    }
}

struct ExhibitionWelcomeCategory: DashboardKit.Category {
    let id: String = "EXHIBITION_WELCOME_MESSAGE"

    let title: LocalizedStringResource = "Exhibition Welcome"

    let description: LocalizedStringResource? = nil

    func content(dashboard: Dashboard, entry: ExhibitionWelcomeEntry) -> some View {
        VStack(alignment: .leading) {
            Text(entry.title)
                .font(.headline)
            Text(entry.text)
        }
    }
}
