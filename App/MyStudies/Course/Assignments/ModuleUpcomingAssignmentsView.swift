//
//  ModuleAssignmentsScrollView.swift
//  My Brighton
//
//  Created by Neo Salmon on 28/08/2025.
//

import SwiftUI
import CoreDesign
import Router
import LearnKit

struct ModuleUpcomingAssignmentsView: View {
    var course: Course

    init(_ course: Course) {
        self.course = course
    }

    var body: some View {
        NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades(nil)) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Upcoming Assignments")
                        .font(.title3.bold())
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.brightonSecondary)
                        .imageScale(.large)
                }

                UpcomingAssignmentsView(for: self.course)
                    .hidesHeader()
                    .showNoContentOnAllHiddenColumns("No Upcoming Assignments")
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}
