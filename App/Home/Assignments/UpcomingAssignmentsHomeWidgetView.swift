//
//  UpcomingAssignmentsHomeWidgetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/04/2026.
//

import SwiftUI
import LearnKit
import Router
import CoreDesign

struct UpcomingAssignmentsHomeWidgetView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.learnKitService) private var learnKit
    @Environment(Router.self) private var router

    @State private var courses: [Course]? = nil

    var body: some View {
        VStack(alignment: .leading) {
            Text("Upcoming Assignments")
                .font(.title3.bold())
                .padding(.horizontal, 16)

            if let courses {
                if !courses.isEmpty {
                    if hSizeClass == .compact {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                rootContent(courses)
                            }
                            .fixedSize()
                            .scrollTargetLayout()
                        }
                        .contentMargins(.horizontal, 16, for: .scrollContent)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                    } else {
                        rootContent(courses)
                            .padding(.horizontal, 16)
                    }
                } else {
                    NoContentView {
                        VStack {
                            Text("All Assignments Submitted")
                            Text("Good job :D")
                                .font(.caption)
                        }
                        .foregroundStyle(.brightonSecondary)
                    }
                    .frame(height: 80)
                    .padding(.horizontal, 16)
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
                    .padding(.horizontal, 16)
            }
        }
        .task {
            do {
                let foundCourses = try await learnKit.getAllCourses()

                let courses: [Course]
                if foundCourses.isEmpty {
                    courses = try await learnKit.refreshCourses()
                } else {
                    courses = foundCourses
                }

                self.courses = try await withThrowingTaskGroup(returning: [Course].self) { group in
                    for course in courses {
                        group.addTask {
                            let cachedColumns = try await learnKit.getAllGradeColumns(for: course.id)

                            let columns: [GradeColumn]
                            if cachedColumns.isEmpty {
                                columns = try await learnKit.refreshGradeColumns(for: course.id)
                            } else {
                                columns = cachedColumns
                            }

                            for column in columns {
                                if await !column.isSubmitted(in: course.id, using: learnKit) {
                                    return (course: course, needsSubmitted: true)
                                }
                            }

                            return (course: course, needsSubmitted: false)
                        }
                    }

                    var courses = [Course]()
                    for try await result in group {
                        if result.needsSubmitted {
                            courses.append(result.course)
                        }
                    }

                    return courses
                }
            } catch {

            }
        }
    }

    @ViewBuilder
    private func rootContent(_ courses: [Course]) -> some View {
        ForEach(courses, id: \.id) { course in
            Button {
                router.navigate(to: .route(.myStudies(.module(course.id, .grades(nil)))))
            } label: {
                UpcomingAssignmentsView(for: course)
            }
            .buttonStyle(.plain)
            .containerRelativeFrame([.horizontal], count: 5, span: 5, spacing: 0)
        }
    }
}
