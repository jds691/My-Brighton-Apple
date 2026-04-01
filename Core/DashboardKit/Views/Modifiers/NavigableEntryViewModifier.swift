//
//  NavigableEntryViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 31/03/2026.
//

import SwiftUI
import Router

struct NavigableEntryViewModifier: ViewModifier {
    @Environment(Router.self) private var router

    let entry: any DashboardEntry

    init(_ entry: any DashboardEntry) {
        self.entry = entry
    }

    func body(content: Content) -> some View {
        if let navigableEntry = entry as? (any NavigableEntry) {
            content
                .onTapGesture {
                    router.navigate(to: navigableEntry.navigationPoint)
                }
        } else {
            content
        }
    }
}
