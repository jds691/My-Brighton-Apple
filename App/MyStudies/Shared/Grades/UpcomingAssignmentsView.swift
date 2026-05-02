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

    private var showNoContentOnAllHiddenColumns: Bool = false
    private var showHeader: Bool = true

    @State private var customisations: CourseCustomisation?
    @State private var thumbnailDidChangeObserver: (any NSObjectProtocol)? = nil
    @State private var thumbnailImage: Image? = nil

    @State private var gradeColumns: [GradeColumn]? = nil
    // Contains the IDs of columns that do not have valid submissions
    @State private var shownColumns: [GradeColumn.ID]? = nil

    init(for course: Course) {
        self.course = course
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let gradeColumns, let shownColumns {
                if showNoContentOnAllHiddenColumns && (gradeColumns.isEmpty || shownColumns.isEmpty) {
                    NoContentView {
                        VStack {
                            Text("All Assignments Submitted")
                            Text("Good job :D")
                                .font(.caption)
                        }
                        .foregroundStyle(.brightonSecondary)
                    }
                    .frame(height: 80)
                } else {
                    displayedView(gradeColumns, shownColumns: shownColumns)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
                    .contraCard()
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
                        self.gradeColumns = []
                        self.shownColumns = []
                        return
                    } else {
                        self.gradeColumns = gradeColumns
                            .sorted(by: { $0.grading.dueDate < $1.grading.dueDate })
                    }
                } else {
                    self.gradeColumns = gradeColumns
                        .sorted(by: { $0.grading.dueDate < $1.grading.dueDate })
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

                            return (columnId: column.id, submitted: await column.isSubmitted(basedOn: attempts))
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
                gradeColumns = []
                shownColumns = []
            }
        }
    }

    @ViewBuilder
    private func displayedView(_ columns: [GradeColumn], shownColumns: [GradeColumn.ID]) -> some View {
        let displayRowColumns = columns.filter({ shownColumns.contains($0.id) })

        if !displayRowColumns.isEmpty {
            VStack(alignment: .leading) {
                if showHeader, let customisations {
                    HStack {
                        if let thumbnailImage {
                            thumbnailImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                                .modifier(TextEffectsViewModifier(customisations.textEffects))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.courseId)
                                .font(customisations.fontDesign.swiftUIFont(.subheadline))
                            Text(customisations.displayNameOverride ?? course.name)
                                .font(customisations.fontDesign.swiftUIFont(.body))
                        }
                        .modifier(TextEffectsViewModifier(customisations.textEffects))
                        .foregroundStyle(customisations.textColor.resolved)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        CustomisedBackgroundView(customisations.background)
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0)
                            .clipped()
                            .blur(radius: 15)
                            .padding([.horizontal, .top], -30)
                    }
                    .onAppear {
                        if let thumbnailUrl = CustomisationService.shared.thumbnailUrl(for: course.id, nilIfNonExistent: true) {
#if canImport(UIKit)
                            if let uiThumbnailImage = UIImage(contentsOfFile: thumbnailUrl.path(percentEncoded: false)) {
                                thumbnailImage = Image(uiImage: uiThumbnailImage)
                            }
#elseif canImport(AppKit)
                            if let nsThumbnailImage = NSImage(contentsOf: thumbnailUrl) {
                                thumbnailImage = Image(nsImage: nsThumbnailImage)
                            }
#endif
                        }

                        thumbnailDidChangeObserver = NotificationCenter.default.addObserver(forName: CustomisationService.thumbnailDidRefresh, object: nil, queue: OperationQueue.main) { notification in
                            guard let courseId = notification.userInfo?["courseId"] as? String, courseId == course.id else { return }

                            MainActor.assumeIsolated {
                                if let thumbnailUrl = CustomisationService.shared.thumbnailUrl(for: course.id, nilIfNonExistent: true) {
#if canImport(UIKit)
                                    if let uiThumbnailImage = UIImage(contentsOfFile: thumbnailUrl.path(percentEncoded: false)) {
                                        thumbnailImage = Image(uiImage: uiThumbnailImage)
                                    }
#elseif canImport(AppKit)
                                    if let nsThumbnailImage = NSImage(contentsOf: thumbnailUrl) {
                                        thumbnailImage = Image(nsImage: nsThumbnailImage)
                                    }
#endif
                                } else {
                                    thumbnailImage = nil
                                }
                            }
                        }
                    }
                    .onDisappear {
                        if let thumbnailDidChangeObserver {
                            NotificationCenter.default.removeObserver(thumbnailDidChangeObserver)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        ForEach(displayRowColumns, id: \.id) { column in
                            UpcomingAssignmentsGradeColumnRow(column)
                        }
                    }
                }
                .padding([.horizontal, .bottom], 16)
                .padding(.top, showHeader && customisations != nil ? 4 : 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contraCard()
        } else {
            EmptyView()
        }
    }
}

extension UpcomingAssignmentsView {
    func hidesHeader(_ hidden: Bool = true) -> Self {
        var view = self
        view.showHeader = !hidden

        return view
    }

    func showNoContentOnAllHiddenColumns(_ show: Bool = true) -> Self {
        var view = self
        view.showNoContentOnAllHiddenColumns = show

        return view
    }
}
