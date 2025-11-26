//
//  ModuleSubrouteNavigationDestination.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import Router
import LearnKit

extension View {
    func moduleSubrouteNavigationDestination(courseId: Course.ID) -> some View {
        self
            .navigationDestination(for: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.self) { route in
                switch route {
                    case .content(let contentId):
                        ContentWrapperView(for: contentId, courseId: courseId)
                    case .grades:
                        ModuleGradesView()
                    default:
                        NoContentView("Invalid route for `Navigation.Route.MyStudiesSubRoute.ModuleSubRoute`")
                }
            }
    }
}
