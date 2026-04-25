//
//  UpcomingAssignmentsView.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/04/2026.
//

import Foundation
import SwiftUI
import LearnKit
import CustomisationKit
import Router
import CoreDesign

struct UpcomingAssignmentsView: View {
    @Environment(\.learnKitService) private var learnKit
    @Environment(Router.self) private var router

    private let course: Course

    private var noContentLocalisedText: LocalizedStringResource? = nil
    private var showHeader: Bool = true

    @State private var customisations: CourseCustomisation?
    @State private var gradeColumns: [GradeColumn]? = nil
    // Contains the IDs of columns that do not have valid submissions
    @State private var shownColumns: [GradeColumn.ID]? = nil

    init(for course: Course) {
        self.course = course
    }

    var body: some View {
        Group {
            if let gradeColumns, let shownColumns {
                if let noContentLocalisedText, gradeColumns.isEmpty || shownColumns.isEmpty {
                    NoContentView(noContentLocalisedText)
                        .frame(height: 80)
                } else {
                    displayedView(gradeColumns, shownColumns: shownColumns)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
                    .background(.brightonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                    .containerShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .strokeBorder(lineWidth: 3, antialiased: true)
                    }
            }
        }
        // Logic
        .task(id: course.id) {
            customisations = CustomisationService.shared.getCourseCustomisation(for: course.id)

            do {
                var gradeColumns = try await learnKit.getAllGradeColumns(for: course.id)

                if gradeColumns.isEmpty {
                    gradeColumns = try await learnKit.refreshGradeColumns(for: course.id)

                    if gradeColumns.isEmpty {
                        shownColumns = []
                        return
                    } else {
                        self.gradeColumns = gradeColumns
                    }
                } else {
                    self.gradeColumns = gradeColumns
                }

                self.shownColumns = try await withThrowingTaskGroup(returning: [GradeColumn.ID].self) { group in
                    guard let columns = self.gradeColumns else { return [] }

                    for column in columns {
                        group.addTask {
                            var attempts = try await learnKit.getGradebookAttempts(for: column.id, in: course.id)

                            if attempts.isEmpty {
                                attempts = try await learnKit.refreshGradebookAttempts(for: column.id, in: course.id)

                                if attempts.isEmpty { return (columnId: column.id, submitted: false) }
                            }

                            switch column.grading.scoringModel {
                                case .last:
                                    return (
                                        columnId: column.id,
                                        submitted: attempts
                                            .sorted(by: { $0.created > $1.created })
                                            .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil
                                        )
                                case .highest:
                                    return (
                                        columnId: column.id,
                                        submitted: attempts
                                            .sorted(by: { ($0.score ?? -1) > ($1.score ?? -1) })
                                            .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil
                                        )
                                case .lowest:
                                    return (
                                        columnId: column.id,
                                        submitted: attempts
                                            .sorted(by: { ($0.score ?? -1) < ($1.score ?? -1) })
                                            .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil
                                        )
                                case .first:
                                    return (
                                        columnId: column.id,
                                        submitted: attempts
                                            .sorted(by: { $0.created < $1.created })
                                            .first(where: { $0.status == .completed || $0.status == .needsGrading || $0.status == .needsMoreGrading }) != nil
                                        )
                                case .average:
                                    return (columnId: column.id, submitted: false)
                            }
                        }
                    }

                    var results = [GradeColumn.ID]()
                    for try await result in group {
                        if !result.submitted {
                            results.append(result.columnId)
                        }
                    }
                    return results
                }
            } catch {

            }
        }
    }

    @ViewBuilder
    private func displayedView(_ columns: [GradeColumn], shownColumns: [GradeColumn.ID]) -> some View {
        VStack(alignment: .leading) {
            if showHeader, let customisations {
                // TODO: Placeholder
                Text(customisations.displayNameOverride ?? course.name)
                    .bold()
            }

            Group {
                ForEach(columns.filter({ shownColumns.contains($0.id) }), id: \.id) { column in
                    UpcomingAssignmentsGradeColumnRow(column)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.brightonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .containerShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .strokeBorder(lineWidth: 3, antialiased: true)
        }
    }
}

extension UpcomingAssignmentsView {
    func hidesHeader(_ hidden: Bool = true) -> Self {
        var view = self
        view.showHeader = !hidden

        return view
    }

    func showNoContentOnAllHiddenColumns(_ displayText: LocalizedStringResource) -> Self {
        var view = self
        view.noContentLocalisedText = displayText

        return view
    }
}
