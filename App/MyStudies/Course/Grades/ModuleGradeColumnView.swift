//
//  ModuleGradeColumnView.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/04/2026.
//

import SwiftUI
import EventKit
#if canImport(EventKitUI)
import EventKitUI
#endif
import LearnKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CoreDesign

struct ModuleGradeColumnView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openUrl

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

    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String? = nil

    var gradedAttempt: GradebookAttempt? {
        guard let gradeColumn, let attempts, !attempts.isEmpty else { return nil }

        switch gradeColumn.grading.scoringModel {
            case .last:
                return attempts
                    .sorted(by: { $0.created > $1.created })
                    .first(where: { $0.status == .completed })
            case .highest:
                return attempts
                    .sorted(by: { ($0.score ?? -1) > ($1.score ?? -1) })
                    .first(where: { $0.status == .completed })
            case .lowest:
                return attempts
                    .sorted(by: { ($0.score ?? -1) < ($1.score ?? -1) })
                    .first(where: { $0.status == .completed })
            case .first:
                return attempts
                    .sorted(by: { $0.created < $1.created })
                    .first(where: { $0.status == .completed })
            case .average:
                return nil
        }
    }

    #if canImport(EventKitUI)
    @State private var eventStore = EKEventStore()
    @State private var showEventAddView: Bool = false
    #endif

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
                        Text("\(NSTextList(markerFormat: .circle, options: 0).marker(forItemNumber: 1)) Please check Blackboard for more information.")
                    }
                } header: {
                    Text("Overview")
                        .font(.title3.bold())
                        .padding(.bottom, -12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let gradedAttempt, let gradeColumn, let attempts {
                    Section {
                        if let attemptIndex = attempts.firstIndex(of: gradedAttempt) {
                            ModuleGradebookAttemptRow(gradeColumn: gradeColumn, attempt: gradedAttempt, attemptNumber: attempts.count - attemptIndex)
                        } else {
                            ModuleGradebookAttemptRow(gradeColumn: gradeColumn, attempt: gradedAttempt, attemptNumber: -1)
                        }
                    } header: {
                        Text("Graded Attempt")
                            .font(.title3.bold())
                            .padding(.bottom, -12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Section {
                    if let gradeColumn, let attempts {
                        if attempts.isEmpty {
                            NoContentView("No Attempts Made")
                                .frame(height: 80)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(attempts.filter({ $0.id != (gradedAttempt?.id ?? "") }), id: \.id) { attempt in
                                    if let attemptIndex = attempts.firstIndex(of: attempt) {
                                        ModuleGradebookAttemptRow(gradeColumn: gradeColumn, attempt: attempt, attemptNumber: attempts.count - attemptIndex)
                                    } else {
                                        ModuleGradebookAttemptRow(gradeColumn: gradeColumn, attempt: attempt, attemptNumber: -1)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text(gradedAttempt != nil ? "Other Attempts" : "Attempts")
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
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                #if canImport(EventKitUI)
                Button {
                    showEventAddView = true
                } label: {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                }
                .disabled(gradeColumn == nil)

                Divider()
                #endif
            }
        }
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .navigationSubtitle(gradeColumn?.grading.dueDate != nil ? "Due: \(dueDateFormatter.string(from: gradeColumn!.grading.dueDate))" : "")
                #if os(macOS)
                    .toolbar {
                        if let onlineUrl {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Open in Blackboard") {
                                    openUrl(onlineUrl, prefersInApp: true)
                                }
                            }
                        }
                    }
                #else
                    .safeAreaBar(edge: .bottom) {
                        if let onlineUrl {
                            Button {
                                openUrl(onlineUrl, prefersInApp: true)
                            } label: {
                                Label("Open in Blackboard", systemImage: "arrow.up.forward.app")
                                    .padding(8)
                            }
                            .buttonStyle(.glassProminent)
                            .padding(.bottom, 16)
                        }
                    }
                #endif
            } else {
                $0
                    .toolbar {
                        ToolbarItemGroup(placement: .principal) {
                            Text("Timetable")
                            Text(gradeColumn?.grading.dueDate != nil ? "Due: \(dueDateFormatter.string(from: gradeColumn!.grading.dueDate))" : "")
                                .foregroundStyle(.brightonSecondary)
                        }

                        #if os(macOS)
                        if let onlineUrl {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Open in Blackboard") {
                                    openUrl(onlineUrl)
                                }
                            }
                        }
                        #endif
                    }
                #if !os(macOS)
                    .safeAreaInset(edge: .bottom) {
                        if let onlineUrl {
                            Button {
                                openUrl(onlineUrl)
                            } label: {
                                Label("Open in Blackboard", systemImage: "arrow.up.forward.app")
                                    .padding(8)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.bottom, 16)
                        }
                    }
                #endif
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
                errorMessage = "Unable to load assignment information."
                showErrorMessage = true
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
                errorMessage = "Unable to load assignment attempts."
                showErrorMessage = true
            }
        }
        .alert("Unable to load assignment", isPresented: $showErrorMessage) {
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
        #if canImport(EventKitUI)
        .sheet(isPresented: $showEventAddView) {
            EventEditView(dueDateEvent)
                .ignoresSafeArea()
        }
        #endif
    }

    #if canImport(EventKitUI)
    private var dueDateEvent: EKEvent? {
        guard let gradeColumn else { return nil }

        let event = EKEvent(eventStore: eventStore)
        event.title = "Assignment: \(gradeColumn.name)"
        event.startDate = gradeColumn.grading.dueDate
        event.endDate = gradeColumn.grading.dueDate
        if let onlineUrl {
            event.url = onlineUrl
        }

        return event
    }
    #endif

    private var onlineUrl: URL? {
        guard let gradeColumn, let contentId = gradeColumn.contentId, let courseId else { return nil }

        return URL(string: "https://studentcentral.brighton.ac.uk/ultra/redirect?redirectType=nautilus&courseId=\(courseId)&contentId=\(contentId)")!
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
