//
//  ContentView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import CoreSpotlight
import Router
import Timetable
import LearnKit
import CustomisationKit

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow

    @Environment(Router.self) private var router: Router
    @Environment(SearchManager.self) private var searchManager: SearchManager
    @Environment(\.timetableService) private var timetableService
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.customisationService) private var customisationService

    @AppStorage(TimetableService.remoteURLUserDefaultsKey) private var timetableURL: URL?

    @State private var courses: [Course] = []
    @State private var courseCustomisations: Dictionary<String, CourseCustomisation> = [:]

    var body: some View {
        @Bindable var router = router
        
        root
            .onContinueRouterUserActivities()
        // Not included in Router due to the dependency on SearchManager
            .onContinueUserActivity(CSQueryContinuationActionType, perform: { userActivity in

                guard let searchString = userActivity.userInfo?[CSSearchQueryString] as? String else {
                    return
                }

                router.navigate(to: .route(.search))
                searchManager.search(for: searchString)
            })
            .sheet(item: $router.rootModal) { requestedModal in
                Group {
                    switch requestedModal {
                        case .account:
                            AccountView()
                        case .timetableSetup:
                            TimetableSetupView()
                    }
                }
            }
    }
    
    @ViewBuilder
    private var root: some View {
        @Bindable var router = router
        @Bindable var searchManager = searchManager

        TabView(selection: $router.currentRoute) {
            Tab(value: .home(nil)) {
                NavigationStack(path: $router.path) {
                    HomeView()
                }
            } label: {
                Navigation.Route.home(nil).label
            }

            Tab(value: .myStudies(nil)) {
                NavigationStack(path: $router.path) {
                    MyStudiesView()
                }
            } label: {
                Navigation.Route.myStudies(nil).label
            }

            #if ENABLE_BSU
            Tab(value: .bsu) {
                NavigationStack(path: $router.path) {
                    SocietiesView()
                }
            } label: {
                Navigation.Route.bsu.label
            }
            #endif
            //.hidden(hSizeClass != .compact)

            TabSection("Courses") {
                ForEach(courses, id: \.id) { course in
                    Tab(value: Navigation.Route.myStudies(.module(course.id, nil))) {
                        NavigationStack(path: $router.path) {
                            CourseView(id: course.id)
                        }
                    } label: {
                        if let customisations = courseCustomisations[course.id] {
                            Text(customisations.displayNameOverride ?? course.name)
                        } else {
                            Text(course.name)
                        }
                    }
                    .contextMenu {
                        if supportsMultipleWindows {
                            Button {
                                openWindow(id: "module", value: course.id)
                            } label: {
                                Label("Open in New Window", systemImage: "macwindow.badge.plus")
                            }
                        }
                    }
                }
            }
#if !os(macOS)
            .hidden(hSizeClass == .compact)
            .defaultVisibility(.hidden, for: .tabBar)
#endif

            if CSSearchableIndex.isIndexingAvailable() {
                Tab(value: .search, role: .search) {
                    NavigationStack(path: $router.path) {
                        SearchView()
                    }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
#if os(macOS)
        .searchable(text: $searchManager.searchTerm, isPresented: $searchManager.isSearching, placement: .sidebar)
#endif
        .task {
            do {
                // TODO: Attempt to remove this later on
                try await learnKit.refreshTerms()
                courses = try await learnKit.getAllCourses()

                if courses.isEmpty {
                    courses = try await learnKit.refreshCourses()
                }

                for course in courses {
                    courseCustomisations.updateValue(customisationService.getCourseCustomisation(for: course.id), forKey: course.id)
                }
            } catch {
            }
        }
    }
}

#Preview(traits: .environmentObjects, .learnKit, .customisationKit) {
    ContentView()
}
