//
//  ModuleGradeColumnView.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/04/2026.
//

import SwiftUI
import LearnKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CoreDesign

struct ModuleGradeColumnView: View {
    @Environment(\.courseId) private var courseId
    @Environment(\.learnKitService) private var learnKit

    private let gradeColumnId: GradeColumn.ID

    private let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    @State private var gradeColumn: GradeColumn? = nil
    @State private var attempts: [GradebookAttempt]? = nil

    init(columnId: GradeColumn.ID) {
        self.gradeColumnId = columnId
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                if let gradeColumn, let attempts {
                    ModuleGradeColumnStatusBanner(column: gradeColumn, attempts: attempts)
                }

                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(NSTextList(markerFormat: .circle, options: 0).marker(forItemNumber: 0)) \(dueDateString)")
                        Text("\(NSTextList(markerFormat: .circle, options: 0).marker(forItemNumber: 1)) Please check My Studies for more information.")
                    }
                } header: {
                    Text("Overview")
                        .font(.title3.bold())
                        .padding(.bottom, -12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Section {
                    if let attempts {
                        if attempts.isEmpty {
                            NoContentView("No Attempts Made")
                                .frame(height: 80)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {

                            }
                        }
                    }
                } header: {
                    Text("Attempts")
                        .font(.title3.bold())
                        .padding(.bottom, -12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .myBrightonBackground()
        .contentMargins(16, for: .scrollContent)
        .navigationTitle(gradeColumn?.name ?? "Assignment")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .navigationSubtitle(gradeColumn?.grading.dueDate != nil ? "Due: \(dueDateFormatter.string(from: gradeColumn!.grading.dueDate))" : "")
                    .safeAreaBar(edge: .bottom) {
                        Button {

                        } label: {
                            Label("Open in My Studies", systemImage: "arrow.up.forward.app")
                                .padding(8)
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(true)
                        .padding(.bottom, 16)
                    }
            } else {
                $0
                    .toolbar {
                        ToolbarItemGroup(placement: .principal) {
                            Text("Timetable")
                            Text(gradeColumn?.grading.dueDate != nil ? "Due: \(dueDateFormatter.string(from: gradeColumn!.grading.dueDate))" : "")
                                .foregroundStyle(.brightonSecondary)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Button {

                        } label: {
                            Label("Open in My Studies", systemImage: "arrow.up.forward.app")
                                .padding(8)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(true)
                        .padding(.bottom, 16)
                    }
            }
        }
        .task(id: gradeColumnId) {
            guard let courseId else { return }
#if DEBUG
            do {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    try await learnKit.refreshCourses()
                }
            } catch {

            }
#endif

            async let gradeColumn = learnKit.getGradeColumn(for: self.gradeColumnId, in: courseId)
            async let attempts = learnKit.getGradebookAttempts(for: self.gradeColumnId, in: courseId)

            do {
                if let foundGradeColumn = try await gradeColumn {
                    self.gradeColumn = foundGradeColumn
                } else {
                    self.gradeColumn = try await learnKit.refreshGradeColumn(for: self.gradeColumnId, in: courseId)
                }
            } catch {
                // TODO: Show error and dismiss
            }

            do {
                let foundAttempts = try await attempts
                if !foundAttempts.isEmpty {
                    self.attempts = foundAttempts
                } else {
                    try await learnKit.refreshGradebookAttempts(for: self.gradeColumnId, in: courseId)
                    self.attempts = try await learnKit.getGradebookAttempts(for: self.gradeColumnId, in: courseId)
                }
            } catch {
                // TODO: Show error and dismiss
            }
        }
    }
}

// MARK: Localisation
extension ModuleGradeColumnView {
    var dueDateString: LocalizedStringResource {
        guard let gradeColumn else { return "" }

        if gradeColumn.grading.dueDate < .now {
            return .init(
                "course.gradecolumn.overview.duedate.past",
                defaultValue: "This assignment was due on **\(dueDateFormatter.string(from: gradeColumn.grading.dueDate))**.",
                table: "My Studies",
            )
        } else {
            return .init(
                "course.gradecolumn.overview.duedate.present",
                defaultValue: "This assignment is due on **\(dueDateFormatter.string(from: gradeColumn.grading.dueDate))**.",
                table: "My Studies",
            )
        }
    }
}

#Preview(traits: .environmentObjects, .learnKit) {
    NavigationStack {
        ModuleGradeColumnView(columnId: "_0_1__0_1")
            .environment(\.courseId, "_0_1")
    }
}
