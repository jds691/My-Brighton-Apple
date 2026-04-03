//
//  MyStudiesView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import Router
import LearnKit
import CoreDesign
import CustomisationKit

struct MyStudiesView: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(Router.self) private var router
    @Environment(\.learnKitService) private var learnKitService

    let columns = [
        // My personally preferred size, 3 cards when the sidebar is open
        GridItem(.adaptive(minimum: 300))
    ]

    @State private var terms: [Term] = []
    @State private var courses: [Course] = []
    @State private var customisations: [CourseCustomisation] = []

    @State private var courseToCustomise: Course? = nil

    @State private var searchTerm: String = ""

    private var favouriteCustomisations: [CourseCustomisation] {
        customisations.filter({ $0.isFavourite })
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 16) {
                if !favouriteCustomisations.isEmpty {
                    Section {
                        ForEach(favouriteCustomisations, id: \.courseId) { customisation in
                            if let course = courses.first(where: { $0.id == customisation.courseId }) {
                                NavigationLink(value: Navigation.Route.MyStudiesSubRoute.module(course.id, nil)) {
                                    MyStudiesCourseCard(course: course, customisations: customisations.first(where: { $0.courseId == course.id })!)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .contextMenu {
                                    if supportsMultipleWindows {
                                        Button {
                                            openWindow(id: "module", value: course.id)
                                        } label: {
                                            Label("Open in New Window", systemImage: "macwindow.badge.plus")
                                        }

                                        Divider()
                                    }

                                    Button {
                                        courseToCustomise = course
                                    } label: {
                                        Label("Customise", systemImage: "paintbrush")
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Favourites")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                ForEach(terms.sorted(by: { $0.id > $1.id }), id: \.id) { term in
                    let coursesInTerm: [Course] = courses.filter({ course in course.termId == term.id && !favouriteCustomisations.contains(where: { $0.courseId == course.id }) })

                    if !coursesInTerm.isEmpty {
                        Section {
                            ForEach(coursesInTerm, id: \.id) { course in
                                NavigationLink(value: Navigation.Route.MyStudiesSubRoute.module(course.id, nil)) {
                                    MyStudiesCourseCard(course: course, customisations: customisations.first(where: { $0.courseId == course.id })!)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .contextMenu {
                                    if supportsMultipleWindows {
                                        Button {
                                            openWindow(id: "module", value: course.id)
                                        } label: {
                                            Label("Open in New Window", systemImage: "macwindow.badge.plus")
                                        }

                                        Divider()
                                    }

                                    Button {
                                        courseToCustomise = course
                                    } label: {
                                        Label("Customise", systemImage: "paintbrush")
                                    }
                                }
                            }
                        } header: {
                            Text(term.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .scenePadding()
        }
        .myBrightonBackground()
        .navigationTitle("My Studies")
        .searchable(text: $searchTerm, prompt: "Search Modules")
        // TODO: Not being called on macOS
        // Idk wtf I'm supposed to do if macOS just won't call it
        // My only immediate guess is that iOS will call navigation destination when it's not on screen but macOS won't. However. Idfk
        // Potentially make one extremely large ViewModifier that contains each navigationDestination call
        .navigationDestination(for: Navigation.Route.MyStudiesSubRoute.self) { subroute in
            switch subroute {
                case .module(let moduleId, _):
                    CourseView(id: moduleId)
            }
        }
        .task {
#if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                do {
                    try await learnKitService.refreshTerms()
                    try await learnKitService.refreshCourses()
                } catch {

                }
            }
#endif

            async let cachedTerms: [Term] = learnKitService.getAllTerms()
            async let cachedCourses: [Course] = learnKitService.getAllCourses()

            do {
                terms = try await cachedTerms
                courses = try await cachedCourses

                customisations = []
                for course in self.courses {
                    customisations.append(CustomisationService.shared.getCourseCustomisation(for: course.id))
                }
            } catch {
                print(error)
            }
        }
        .refreshable {
            do {
                updateAndReplaceTerms(try await learnKitService.refreshTerms())
                updateAndReplaceCourses(try await learnKitService.refreshCourses())
            } catch {
                print(error)
            }
        }
        .sheet(item: $courseToCustomise) { course in
            CourseCustomisationEditView(for: course.id, userCourseId: course.courseId, realName: course.name)
        }
    }

    private func updateAndReplaceTerms(_ newTerms: [Term]) {
        for newTerm in newTerms {
            if let termsIndex = terms.firstIndex(where: { $0.id == newTerm.id }) {
                terms[termsIndex] = newTerm
            } else {
                terms.append(newTerm)
            }
        }
    }

    private func updateAndReplaceCourses(_ newCourses: [Course]) {
        for newCourse in newCourses {
            if let coursesIndex = courses.firstIndex(where: { $0.id == newCourse.id }) {
                courses[coursesIndex] = newCourse
            } else {
                courses.append(newCourse)
                customisations.append(CustomisationService.shared.getCourseCustomisation(for: newCourse.id))
            }
        }
    }
}

#Preview(traits: .environmentObjects, .learnKit, .customisationKit) {
    @Previewable @State var router = Router.shared
    
    TabView {
        Tab {
            NavigationStack(path: $router.path) {
                MyStudiesView()
            }
        } label: {
            Label("My Studies", systemImage: "graduationcap")
        }
    }
    .environment(router)
}
