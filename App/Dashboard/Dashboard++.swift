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

enum DashboardID: String, CaseIterable {
    case yourUpdates = "inbox"
    case importantUpdates = "important"

    public var dashboard: Dashboard {
        return Dashboard(self.rawValue, categories: self.categories)
    }

    public var categories: [any DashboardKit.Category] {
        switch self {
            case .importantUpdates:
                [
                    ExhibitionWelcomeCategory(),
                    GradebookColumnOverdueCategory()
                ]
            case .yourUpdates:
                [
                    GradebookColumnDueCategory()
                ]
        }
    }
}
