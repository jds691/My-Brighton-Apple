//
//  DashboardKit+Gradebook.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/05/2026.
//

import Foundation
import DashboardKit
import SwiftData
import SwiftUI
import Router
import LearnKit
import CustomisationKit

// MARK: Due

@Model
class GradebookColumnDueEntry: DashboardEntry, NavigableEntry {
    @Transient
    var navigationPoint: Navigation {
        Navigation.route(.myStudies(.module(courseId, .grades(columnId))))
    }

    var id: String
    var creationDate: Date

    var columnId: GradeColumn.ID
    var courseId: Course.ID

    required init() {
        self.id = ""
        self.columnId = ""
        self.courseId = ""
        self.creationDate = .now
    }

    init(courseId: Course.ID, columnId: GradeColumn.ID) {
        self.id = "gradebook/\(courseId)/\(columnId)"
        self.columnId = columnId
        self.courseId = courseId
        self.creationDate = .now
    }
}

struct GradebookColumnDueCategory: DashboardKit.Category {
    let id: String = "GRADEBOOK_COLUMN_DUE"

    let title: LocalizedStringResource = "Assignment Due"

    let description: LocalizedStringResource? = nil

    func content(dashboard: Dashboard, entry: GradebookColumnDueEntry) -> some View {
        GradebookColumnDueView(dashboard: dashboard, entry: entry)
    }
}

struct GradebookColumnDueView: View {
    @Environment(\.learnKitService) private var learnKit

    private let dashboard: Dashboard
    private let entry: GradebookColumnDueEntry

    private let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    @State private var gradebookColumn: GradeColumn? = nil
    @State private var course: Course? = nil
    @State private var courseCustomisations: CourseCustomisation? = nil

    init(dashboard: Dashboard, entry: GradebookColumnDueEntry) {
        self.dashboard = dashboard
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let course, let gradebookColumn, let courseCustomisations {
                Text("\(gradebookColumn.name) due soon in \(courseCustomisations.displayNameOverride ?? course.name)")
                    .font(.headline)
                Text("This assignment is due on \(dueDateFormatter.string(from: gradebookColumn.grading.dueDate)).")
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .task {
            self.courseCustomisations = CustomisationService.shared.getCourseCustomisation(for: entry.courseId)

            let localCourseId = entry.courseId
            let localColumnId = entry.columnId

            async let foundCourse = try? await learnKit.getCourse(for: localCourseId)
            async let foundColumn = try? await learnKit.getGradeColumn(for: localColumnId, in: localCourseId)

            self.course = await foundCourse
            self.gradebookColumn = await foundColumn

            if gradebookColumn == nil || course == nil {
                print("GradebookColumnDueEntry cannot be loaded. Removing from dashboard")
                #if DEBUG
                dump(entry)
                #endif
                try? dashboard.deleteEntry(by: entry.id, for: GradebookColumnDueEntry.self)
            }
        }
    }
}

// MARK: Overdue

@Model
class GradebookColumnOverdueEntry: DashboardEntry, NavigableEntry {
    @Transient
    var navigationPoint: Navigation {
        Navigation.route(.myStudies(.module(courseId, .grades(columnId))))
    }

    var id: String
    var creationDate: Date

    var columnId: GradeColumn.ID
    var courseId: Course.ID

    required init() {
        self.id = ""
        self.columnId = ""
        self.courseId = ""
        self.creationDate = .now
    }

    init(courseId: Course.ID, columnId: GradeColumn.ID) {
        self.id = "gradebook/\(courseId)/\(columnId)"
        self.columnId = columnId
        self.courseId = courseId
        self.creationDate = .now
    }
}

struct GradebookColumnOverdueCategory: DashboardKit.Category {
    let id: String = "GRADEBOOK_COLUMN_OVERDUE"

    let title: LocalizedStringResource = "Assignment Overdue"

    let description: LocalizedStringResource? = nil

    func content(dashboard: Dashboard, entry: GradebookColumnOverdueEntry) -> some View {
        GradebookColumnOverdueView(dashboard: dashboard, entry: entry)
    }
}

struct GradebookColumnOverdueView: View {
    @Environment(\.learnKitService) private var learnKit

    private let dashboard: Dashboard
    private let entry: GradebookColumnOverdueEntry

    private let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    @State private var gradebookColumn: GradeColumn? = nil
    @State private var course: Course? = nil
    @State private var courseCustomisations: CourseCustomisation? = nil

    init(dashboard: Dashboard, entry: GradebookColumnOverdueEntry) {
        self.dashboard = dashboard
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let course, let gradebookColumn, let courseCustomisations {
                Text("\(gradebookColumn.name) overdue in \(courseCustomisations.displayNameOverride ?? course.name)")
                    .font(.headline)
                Text("This assignment is overdue but submissions may still be possible.\n\nRefer to Blackboard for more information.")
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .task {
            self.courseCustomisations = CustomisationService.shared.getCourseCustomisation(for: entry.courseId)

            let localCourseId = entry.courseId
            let localColumnId = entry.columnId

            async let foundCourse = try? await learnKit.getCourse(for: localCourseId)
            async let foundColumn = try? await learnKit.getGradeColumn(for: localColumnId, in: localCourseId)

            self.course = await foundCourse
            self.gradebookColumn = await foundColumn

            if gradebookColumn == nil || course == nil {
                print("GradebookColumnOverdueEntry cannot be loaded. Removing from dashboard")
#if DEBUG
                dump(entry)
#endif
                try? dashboard.deleteEntry(by: entry.id, for: GradebookColumnDueEntry.self)
            }
        }
    }
}
