//
//  DashboardKit+Previews.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/03/2026.
//

import SwiftUI
import DashboardKit

struct DashboardKitPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> DashboardService {
        return DashboardService(inMemory: true, dashboards: DashboardID.allCases.map(\.dashboard))
    }

    func body(content: Self.Content, context: DashboardService) -> some View {
        content
            .environment(\.dashboardService, context)
    }
}

extension PreviewTrait {
    static var dashboardKit: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(DashboardKitPreviewModifier())
        )
    }
}
