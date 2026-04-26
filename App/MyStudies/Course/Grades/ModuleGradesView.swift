//
//  ModuleGradesView.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/07/2025.
//

import SwiftUI
import LearnKit
import Router

struct ModuleGradesView: View {
    @Environment(\.courseId) private var courseId
    @Environment(\.learnKitService) private var learnKit

    @State private var columns: [GradeColumn]? = nil
    @State private var attempts: [GradeColumn.ID: [GradebookAttempt]]? = nil

    var body: some View {
        Group {
            if let courseId, let columns, let attempts {
                List {
                    ForEach(columns, id: \.id) { column in
                        NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades(column.id)) {
                            UpcomingAssignmentsGradeColumnRow(column)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                ProgressView()
                    .task {
                        guard let courseId else { return }
                        do {
                            let cachedColumns = try await learnKit.getAllGradeColumns(for: courseId)

                            let targetColumns: [GradeColumn]
                            if cachedColumns.isEmpty {
                                targetColumns = try await learnKit.refreshGradeColumns(for: courseId)
                            } else {
                                targetColumns = cachedColumns
                            }

                            self.attempts = try await withThrowingTaskGroup(returning: [GradeColumn.ID: [GradebookAttempt]].self) { group in
                                for column in targetColumns {
                                    group.addTask {
                                        let cachedAttempts = try await learnKit.getGradebookAttempts(for: column.id, in: courseId)

                                        let targetAttempts: [GradebookAttempt]
                                        if cachedAttempts.isEmpty {
                                            targetAttempts = try await learnKit.refreshGradebookAttempts(for: column.id, in: courseId)
                                        } else {
                                            targetAttempts = cachedAttempts
                                        }

                                        return (columnId: column.id, attempts: targetAttempts)
                                    }
                                }

                                var attemptsDict: [GradeColumn.ID: [GradebookAttempt]] = [:]
                                for try await result in group {
                                    attemptsDict.updateValue(result.attempts, forKey: result.columnId)
                                }

                                return attemptsDict
                            }

                            self.columns = targetColumns
                        } catch {
                            // TODO: Show error and return
                        }
                    }
            }
        }
        .navigationTitle("Assignments")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview(traits: .learnKit, .environmentObjects) {
    NavigationStack {
        ModuleGradesView()
    }
}
