//
//  ModuleSubrouteNavigationDestination.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import Router
import LearnKit

fileprivate struct ModuleSubrouteNavigationDestinationViewModifier: ViewModifier {
    @Environment(\.courseId) private var courseId

    func body(content: Self.Content) -> some View {
        content
            .navigationDestination(for: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.self) { route in
                switch route {
                    case .content(let contentId):
                        ContentWrapperView(for: contentId)
                            .environment(\.courseId, courseId)
                    case .grades:
                        ModuleGradesView()
                            .environment(\.courseId, courseId)
                    default:
                        NoContentView("Invalid route for `Navigation.Route.MyStudiesSubRoute.ModuleSubRoute`")
                }
            }
    }
}

extension View {
    func moduleSubrouteNavigationDestination() -> some View {
        self
            .modifier(ModuleSubrouteNavigationDestinationViewModifier())
    }
}
