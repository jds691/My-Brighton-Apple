//
//  UpcomingAssignmentsGradeColumnRow.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/04/2026.
//

import Foundation
import SwiftUI
import LearnKit
import CoreDesign

struct UpcomingAssignmentsGradeColumnRow: View {
    let gradeColumn: GradeColumn

    private let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    init(_ gradeColumn: GradeColumn) {
        self.gradeColumn = gradeColumn
    }

    var body: some View {
        HStack(spacing: 8) {
            icon
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(gradeColumn.name)
                    .font(.headline)

                Text("Due: \(dueDateFormatter.string(from: gradeColumn.grading.dueDate))")
                    .font(.subheadline)
                    .foregroundStyle(gradeColumn.grading.dueDate < .now ? .red : .brightonSecondary)
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch gradeColumn.scoreProviderHandle {
            default:
                Image(systemName: "questionmark.text.page")
                    .resizable()
                    .scaledToFit()
        }
    }
}
