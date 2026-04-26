//
//  ModuleGradesView.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/07/2025.
//

import SwiftUI
import LearnKit
import Router
import CoreDesign

struct ModuleGradesView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(\.courseId) private var courseId
    @Environment(\.learnKitService) private var learnKit

    @State private var columns: [GradeColumn]? = nil
    @State private var attempts: [GradeColumn.ID: [GradebookAttempt]]? = nil

    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if let columns, let attempts {
                let pendingAssignments: [GradeColumn] = columns
                    .filter({ !$0.isSubmitted(basedOn: attempts[$0.id] ?? []) })
                    .sorted(by: { $0.grading.dueDate < $1.grading.dueDate })
                let submittedAssignments: [GradeColumn] = columns
                    .filter({ $0.isSubmitted(basedOn: attempts[$0.id] ?? []) })
                    .sorted(by: { $0.grading.dueDate < $1.grading.dueDate })

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        if !pendingAssignments.isEmpty {
                            Section {
                                ForEach(pendingAssignments, id: \.id) { column in
                                    NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades(column.id)) {
                                        UpcomingAssignmentsGradeColumnRow(column)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(16)
                                            .contraCard()
                                    }
                                    .buttonStyle(.plain)
                                }
                            } header: {
                                Text("Due Assignments")
                                    .font(.title3.bold())
                                    .padding(.bottom, -12)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if !submittedAssignments.isEmpty {
                            Section {
                                ForEach(submittedAssignments, id: \.id) { column in
                                    NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades(column.id)) {
                                        UpcomingAssignmentsGradeColumnRow(column)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(16)
                                            .contraCard()
                                    }
                                    .buttonStyle(.plain)
                                }
                            } header: {
                                Text("Submitted Assignments")
                                    .font(.title3.bold())
                                    .padding(.bottom, -12)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .contentMargins(16, for: .scrollContent)
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
                            errorMessage = error.localizedDescription
                            showErrorMessage = true
                        }
                    }
                    .alert("Unable to load assignments", isPresented: $showErrorMessage) {
                        Button("OK") {
                            dismiss()
                            errorMessage = nil
                        }
                    } message: {
                        if let errorMessage {
                            Text(errorMessage)
                        } else {
                            Text("An unknown error occurred.")
                        }
                    }
            }
        }
        .myBrightonBackground()
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
