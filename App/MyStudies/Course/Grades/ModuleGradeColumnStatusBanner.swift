//
//  ModuleGradeColumnStatusBanner.swift
//  My Brighton
//
//  Created by Neo Salmon on 22/04/2026.
//

import SwiftUI
import LearnKit

struct ModuleGradeColumnStatusBanner: View {
    private let column: GradeColumn
    private let attempts: [GradebookAttempt]

    init(column: GradeColumn, attempts: [GradebookAttempt]) {
        self.column = column
        self.attempts = attempts
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                icon
                    .frame(width: 24, height: 24)
                Text(statusText)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(statusColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .containerShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .strokeBorder(lineWidth: 3, antialiased: true)
        }
    }

    @ViewBuilder
    private var icon: some View {
        if let mostRecentAttempt = attempts.sorted(by: { $0.created > $1.created }).first, mostRecentAttempt.status == .completed || mostRecentAttempt.status == .needsGrading || mostRecentAttempt.status == .needsMoreGrading {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "info.circle")
                .resizable()
                .scaledToFit()
        }
    }

    private var statusText: LocalizedStringResource {
        if let mostRecentAttempt = attempts.sorted(by: { $0.created > $1.created }).first, mostRecentAttempt.status == .completed || mostRecentAttempt.status == .needsGrading || mostRecentAttempt.status == .needsMoreGrading {
            return .init(
                "course.gradecolumn.status.submitted",
                defaultValue: "This assignment has been submitted.",
                table: "My Studies",
            )
        } else if column.grading.dueDate < .now {
            return .init(
                "course.gradecolumn.status.overdue",
                defaultValue: "This assignment is overdue.\n\n**Late submissions may still be possible.** Check Blackboard online for more information.",
                table: "My Studies",
            )
        } else {
            return .init(
                "course.gradecolumn.status.due",
                defaultValue: "This assignment has not been submitted yet.",
                table: "My Studies",
            )
        }
    }

    private var statusColor: Color {
        if let mostRecentAttempt = attempts.sorted(by: { $0.created > $1.created }).first, mostRecentAttempt.status == .completed || mostRecentAttempt.status == .needsGrading || mostRecentAttempt.status == .needsMoreGrading {
            return .Gradebook.statusSubmitted
        } else {
            return .Gradebook.statusWarning
        }
    }
}
