//
//  ModuleGradeColumnView.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/04/2026.
//

import SwiftUI
import LearnKit

struct ModuleGradeColumnView: View {
    @Environment(\.courseId) private var courseId
    @Environment(\.learnKitService) private var learnKit

    private let gradeColumnId: GradeColumn.ID

    @State private var gradeColumn: GradeColumn? = nil
    @State private var attempts: [GradebookAttempt]? = nil

    init(columnId: GradeColumn.ID) {
        self.gradeColumnId = columnId
    }

    var body: some View {
        ScrollView(.vertical) {
            if let gradeColumn, let attempts {
                ModuleGradeColumnStatusBanner(column: gradeColumn, attempts: attempts)
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

#Preview(traits: .environmentObjects, .learnKit) {
    NavigationStack {
        ModuleGradeColumnView(columnId: "_0_1__0_1")
            .environment(\.courseId, "_0_1")
    }
}
