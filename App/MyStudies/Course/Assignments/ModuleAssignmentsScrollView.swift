//
//  ModuleAssignmentsScrollView.swift
//  My Brighton
//
//  Created by Neo Salmon on 28/08/2025.
//

import SwiftUI
import CoreDesign
import Router

struct ModuleAssignmentsScrollView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.dueDates) {
                HStack {
                    Text("Upcoming Assignments")
                        .font(.title3.bold())
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.brightonSecondary)
                        .imageScale(.large)
                }

            }
            .buttonStyle(.plain)

            NoContentView("No Upcoming Assignments")
        }
    }

    private var containerFrameSpan: Int {
        hSizeClass == .compact ? 5 : 2
    }
}

#Preview {
    ModuleAssignmentsScrollView()
        .scenePadding()
        .scrollClipDisabled()
}
