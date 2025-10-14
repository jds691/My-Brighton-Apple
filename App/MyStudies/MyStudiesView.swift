//
//  MyStudiesView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import Router
import LearnKit

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

    @State private var searchTerm: String = ""
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(terms.sorted(by: { $0.id > $1.id }), id: \.id) { term in
                    Section {
                        ForEach(courses.filter({ $0.termId == term.id }), id: \.id) { course in
                            NavigationLink(value: Navigation.Route.MyStudiesSubRoute.module(course.id, nil)) {
                                MyStudiesCourseCard(course: course)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .contextMenu {
                                if supportsMultipleWindows {
                                    Button {
                                        openWindow(id: "module", value: "0")
                                    } label: {
                                        Label("Open in New Window", systemImage: "macwindow.badge.plus")
                                    }

                                    Divider()
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
            async let cachedTerms: [Term] = learnKitService.getAllTerms()
            async let cachedCourses: [Course] = learnKitService.getAllCourses()

            do {
                terms = try await cachedTerms
                courses = try await cachedCourses
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
            }
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview(traits: .environmentObjects, .learnKit) {
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
