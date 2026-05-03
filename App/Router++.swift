//
//  Router++.swift
//  My Brighton
//
//  Created by Neo Salmon on 16/09/2025.
//

import SwiftUI
import Router

extension Navigation.Route {
    @ViewBuilder
    var label: some View {
        switch self {
            case .home:
                Label("Home", image: .uniLogo)
            case .myStudies:
                Label("My Studies", systemImage: "graduationcap")
            case .search:
                Label("Search", systemImage: "magnifyingglass")
            case .bsu:
                Label("Societies", systemImage: "figure")
        }
    }
}
