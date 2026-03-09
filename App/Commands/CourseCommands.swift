//
//  CoyrseCommands.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/06/2025.
//

import SwiftUI
import LearnKit

struct CourseCommands: Commands {
    @FocusedValue(\.courseId) private var courseId: Course.ID?

    var body: some Commands {
        CommandMenu("Course") {
            NavigationLink {
                ModuleGradesView()
            } label: {
                Label("Grades", systemImage: "checkmark.seal.text.page")
            }
            .disabled(courseId == nil)

            NavigationLink {
                ModuleGradesView()
            } label: {
                Label("Due Dates", systemImage: "calendar.badge.clock")
            }
            .disabled(courseId == nil)

            NavigationLink {
                ModuleGradesView()
            } label: {
                Label("Messages", systemImage: "envelope")
            }
            .disabled(courseId == nil)
        }
    }
}

extension FocusedValues {
    @Entry var courseId: Course.ID?
}
