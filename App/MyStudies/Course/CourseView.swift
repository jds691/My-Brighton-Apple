//
//  ModuleView.swift
//  My Brighton
//
//  Created by Neo on 09/09/2023.
//

import SwiftBbML
import SwiftUI
import Glur
import LearnKit
import Router
import AppIntents

struct CourseView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismiss) private var dismiss
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.learnKitService) private var learnKit

    private var courseId: Course.ID

    @State private var course: Course? = nil
    @State private var rootContent: Content? = nil

    @State private var showAnnouncementModal: Bool = false
    @State private var announcements: [any Announcement]? = nil
    @State private var selectedAnnouncement: (any Announcement)? = nil

    @State private var scrollPosition: CGPoint = .zero
    @State private var showTitle: Bool = false

    init(id: Course.ID) {
        self.courseId = id
    }
    
    var body: some View {
        ScrollView(.vertical) {
                header
                    .flexibleHeaderContent()
                VStack(alignment: .leading, spacing: 16) {
                    ModuleAssignmentsScrollView()
                    ModuleAnnouncementsScrollView(announcements: $announcements, onAnnouncementTapped: presentAnnouncement)
                    content
                }
                .scenePadding(.horizontal)
                #if os(iOS)
                // TODO: Check if this can be replaced with onScrollViewGeometryChanged?
                .background(GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollPosition = value
                }
                #endif
            }
            .flexibleHeaderScrollView()
            .ignoresSafeArea(edges: [.top])
            .focusedSceneValue(\.courseId, self.courseId)
            .myBrightonBackground()
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .coordinateSpace(.named("scroll"))
            .modifierBranch { // Hiding the scroll edge effect for the header
                if #available(iOS 26, macOS 26, *) {
                    $0
                        .scrollEdgeEffectHidden(!showTitle, for: [.top])
                } else {
                    $0
                }
            }

            // TODO: If the user was searching in MyStudiesView before opening ModuleView both toolbars display at the same time
            .onChange(of: scrollPosition.y) {
                // TODO: Sync with FlexibleHeader?
                //print(scrollPosition.y)
                if scrollPosition.y < 10 && !showTitle {
                    withAnimation {
                        showTitle = true
                    }
                } else if scrollPosition.y >= 10 && showTitle {
                    withAnimation {
                        showTitle = false
                    }
                }
            }
#endif
            .navigationTitle(course?.name ?? courseId)
        // TODO: Add back when working
            /*.task {
                do {
                    try await IntentDonationManager.shared.donate(intent: OpenCourseIntent(course: CourseEntity(id: .primary(id), name: name, imageName: "nature20_thumb")))
                } catch {

                }
            }*/
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addContentMenu
                }
                // Layout breaks when put in ToolbarItemGroup instead
                ToolbarItemGroup(placement: .secondaryAction) {
                    //optionsMenu
                    //optionsMenuContent
                    Section {
                        NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades) {
                            Label("Grades", systemImage: "checkmark.seal.text.page")
                        }

                        NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.dueDates) {
                            Label("Due Dates", systemImage: "calendar.badge.clock")
                        }

                        NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.messages(nil)) {
                            Label("Messages", systemImage: "envelope")
                        }
                    }

                    Button {

                    } label: {
                        Label("Favourite", systemImage: "star")
                    }

                    Section("People") {
                        Button {

                        } label: {
                            Label("Course Staff", systemImage: "graduationcap")
                        }

                        Button {

                        } label: {
                            Label("Class Register", systemImage: "person.2")
                        }
                    }

                    Menu {
                        Section("Available Tools") {
                            Button {

                            } label: {
                                Label {
                                    Text("Panopto")
                                } icon: {
                                    Image("panopto.logo")
                                }
                            }
                        }
                    } label: {
                        Label("Teaching Tools", systemImage: "wrench.adjustable")
                    }
                }
            }
#if os(iOS)
            .modifierBranch {
                if #available(iOS 26, macOS 26, *) {
                    $0
                        .toolbar {
                            ToolbarItem(placement: .title) {
                                if showTitle {
                                    Text(course?.name ?? courseId)
                                        .font(.headline)
                                        .lineLimit(1)
                                } else {
                                    Text("")
                                }
                            }
                        }
                } else {
                    $0
                        .toolbar(showTitle ? .visible : .hidden, for: .navigationBar)
                        //.toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                        .legacyToolbar(visible: !showTitle, showBackButton: true) {
                            addContentMenu

                            Menu {
                                Section {
                                    NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades) {
                                        Label("Grades", systemImage: "checkmark.seal.text.page")
                                    }

                                    NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.dueDates) {
                                        Label("Due Dates", systemImage: "calendar.badge.clock")
                                    }

                                    NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.messages(nil)) {
                                        Label("Messages", systemImage: "envelope")
                                    }
                                }

                                Button {

                                } label: {
                                    Label("Favourite", systemImage: "star")
                                }

                                Section("People") {
                                    Button {

                                    } label: {
                                        Label("Course Staff", systemImage: "graduationcap")
                                    }

                                    Button {

                                    } label: {
                                        Label("Class Register", systemImage: "person.2")
                                    }
                                }

                                Menu {
                                    Section("Available Tools") {
                                        Button {

                                        } label: {
                                            Label {
                                                Text("Panopto")
                                            } icon: {
                                                Image("panopto.logo")
                                            }
                                        }
                                    }
                                } label: {
                                    Label("Teaching Tools", systemImage: "wrench.adjustable")
                                }
                            } label: {
                                Label("More Options", systemImage: "ellipsis.circle")
                            }
                        }
                }
            }
            
#endif
            .moduleSubrouteNavigationDestination(onAnnouncementTapped: presentAnnouncement)
            .task {
                do {
                    #if DEBUG
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        try await learnKit.refreshCourses()
                    }
                    #endif
                    course = try await learnKit.getCourse(for: courseId)
                    print(course)

                    do {
                        rootContent = try await learnKit.refreshContent(for: "ROOT", includeChildren: false, in: courseId).first
                    } catch {
                        rootContent = try await learnKit.getContent(for: "ROOT", in: courseId)
                    }

                    assert(rootContent != nil)

                    do {
                        announcements = try await learnKit.refreshCourseAnnouncements(for: courseId)
                    } catch {
                        announcements = try await learnKit.getAllCourseAnnouncements(for: courseId)
                    }

                    assert(announcements != nil)

                    print("Loaded course")
                } catch {
                    print(error)
                }
            }
            .refreshable {
                do {
                    async let updatedRootContent = try learnKit.refreshContent(for: "ROOT", in: courseId)
                    async let updatedCourses = try learnKit.refreshCourses()
                    async let updatedAnnouncements = try learnKit.refreshCourseAnnouncements(for: courseId)

                    if let updatedPresentedCourse = try await updatedCourses.first(where: { $0.id == courseId }) {
                        course = updatedPresentedCourse
                    }

                    try await mergeAnnouncements(with: updatedAnnouncements)

                    try await updatedRootContent

                } catch {
                    print(error)
                }
            }
            .sheet(isPresented: $showAnnouncementModal, onDismiss: { selectedAnnouncement = nil }) {
                if let selectedAnnouncement {
                    AnnouncementView(announcement: selectedAnnouncement)
                        .environment(\.courseId, courseId)
                } else {
                    EmptyView()
                        .onAppear {
                            dismiss()
                        }
                }
            }
            .environment(\.courseId, courseId)
    }

    @ViewBuilder
    private var header: some View {
        Rectangle()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .foregroundStyle(.brightonSecondary)
            .clipped()
        // TODO: Add image back
        /*ModuleImageView(image: image) {
            $0
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
        }*/
        .headerBlur()
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .backgroundExtensionEffect()
            } else {
                $0
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading) {
                if let course {
                    Text(course.courseId)
                        .font(.title3)
                    Text(course.name)
                        .lineLimit(2)
                        .font(.largeTitle.bold())
                } else {
                    Text(courseId)
                        .font(.title3)
                        .redacted(reason: .placeholder)
                    Text("YEAR MODULE LONG COURSE NAME")
                        .lineLimit(2)
                        .font(.largeTitle.bold())
                        .redacted(reason: .placeholder)
                }
            }
            .foregroundStyle(.white)
            .scenePadding()
            .padding(.bottom, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)

    }
    
    @ViewBuilder
    private var content: some View {
        Section {
            if let rootContent {
                ContentChildrenListView(for: rootContent.id)
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        } header: {
            Text("Content")
                .font(.title3.bold())
        }
    }

    private var addContentMenu: some View {
        Menu {
            Button {

            } label: {
                Label("Create Content", systemImage: "doc")
            }

            Button {

            } label: {
                Label("Create Discussion", systemImage: "message")
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }

    private func mergeAnnouncements(with newAnnonucements: [CourseAnnouncement]) {
        guard var announcements else { return }

        for newContent in newAnnonucements {
            if let replacementIndex = announcements.firstIndex(where: { $0.id == newContent.id }) {
                announcements[replacementIndex] = newContent
            } else {
                announcements.append(newContent)
            }
        }

        announcements.sort(by: { $0.position < $1.position })
    }

    private func presentAnnouncement(_ announcement: any Announcement) {
        showAnnouncementModal = false
        
        #if os(macOS)
        if supportsMultipleWindows {
            openWindow(id: "course-announcement", value: CourseAnnouncementIDUnion(courseId: courseId, announcementId: announcement.id))
        } else {
            selectedAnnouncement = announcement
            showAnnouncementModal = true
        }
        #else
        selectedAnnouncement = announcement
        showAnnouncementModal = true
        #endif
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

#Preview(traits: .learnKit, .environmentObjects) {
    TabView {
        Tab("Module", systemImage: "graduationcap") {
            NavigationStack {
                CourseView(id: "_0_1")
            }
        }
    }
    .tabViewStyle(.sidebarAdaptable)
}
