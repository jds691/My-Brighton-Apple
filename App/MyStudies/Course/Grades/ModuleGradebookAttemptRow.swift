//
//  ModuleGradebookAttemptRow.swift
//  My Brighton
//
//  Created by Neo Salmon on 22/04/2026.
//

import SwiftUI
import LearnKit
import CoreDesign

struct ModuleGradebookAttemptRow: View {
    let column: GradeColumn
    let attempt: GradebookAttempt
    let attemptNumber: Int

    init(gradeColumn: GradeColumn, attempt: GradebookAttempt, attemptNumber: Int) {
        self.column = gradeColumn
        self.attempt = attempt
        self.attemptNumber = attemptNumber
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "trophy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading) {
                    Text("Attempt #\(attemptNumber)")
                        .font(.headline)
                }
            }

            Spacer()

            if attempt.status == .completed, let score = attempt.score {
                Text("\(score, format: .number.precision(.fractionLength(1))) **/** \(column.possibleScore, format: .number.precision(.fractionLength(1)))")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background {
                        Capsule()
                            .foregroundStyle(.brightonSecondary)
                    }
            } else {
                Text("-**/**-")
                    .frame(minWidth: 73)
                    .foregroundStyle(.brightonSecondary)
                    .padding(8)
                    .background {
                        Capsule()
                            .foregroundStyle(.brightonBackground)
                            .overlay {
                                Capsule()
                                    .strokeBorder(lineWidth: 3, antialiased: true)
                                    .foregroundStyle(.brightonSecondary)
                            }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .contraCard()
    }
}
