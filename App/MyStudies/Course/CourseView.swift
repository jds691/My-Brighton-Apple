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
    @Environment(\.learnKitService) private var learnKit

    private var courseId: Course.ID

    @State private var course: Course? = nil

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
                    ModuleAnnouncementsScrollView()
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
            .userActivity("com.neo.My-Brighton.course.view") { userActivity in

                userActivity.title = "Viewing content in \(course?.name ?? courseId)"
                // To later be replaced with the externalUrl property from the response
                userActivity.webpageURL = course?.externalAccessUrl ?? URL(string: "https://studentcentral.brighton.ac.uk/ultra/courses/\(courseId)/outline")
                userActivity.isEligibleForHandoff = true
                if #available(iOS 18.2, macOS 15.2, *) {
                    userActivity.appEntityIdentifier = .init(for: CourseEntity.self, identifier: courseId)
                }
            }
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
                            .font(.custom("Avenir-Medium", size: 17, relativeTo: .body))
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
                                        .font(.custom("Avenir-Heavy", size: 17, relativeTo: .body))
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
                                        .font(.custom("Avenir-Medium", size: 17, relativeTo: .body))
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
            .navigationDestination(for: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.self) { route in
                switch route {
                    case .grades:
                        ModuleGradesView()
                    default:
                        NoContentView("Invalid route for `Navigation.Route.MyStudiesSubRoute.ModuleSubRoute`")
                }
            }
            .task {
                do {
                    course = try await learnKit.getCourse(for: courseId)

                    print("Loaded course")
                } catch {
                    print(error)
                }
            }
            .refreshable {
                do {
                    let updatedCourses = try await learnKit.refreshCourses()

                    if let updatedPresentedCourse = updatedCourses.first(where: { $0.id == courseId }) {
                        course = updatedPresentedCourse
                    }
                } catch {
                    print(error)
                }
            }
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
                        .font(.custom("Avenir-Medium", size: 20, relativeTo: .title3))
                    Text(course.name)
                        .lineLimit(2)
                        .font(.custom("Avenir-Heavy", size: 34, relativeTo: .largeTitle))
                } else {
                    Text(courseId)
                        .font(.custom("Avenir-Medium", size: 20, relativeTo: .title3))
                        .redacted(reason: .placeholder)
                    Text("YEAR MODULE LONG COURSE NAME")
                        .lineLimit(2)
                        .font(.custom("Avenir-Heavy", size: 34, relativeTo: .largeTitle))
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
            LazyVStack(alignment: .leading) {
                let linkAttributedString: AttributedString = {
                    var string = AttributedString("Dog (Wikipedia)")
                    string.link = URL(string: "https://en.wikipedia.org/wiki/Dog")!

                    return string
                }()
                
                NavigationLink {
                    BbMLContentViewer(
                        BbMLContent(
                            header: .init(),
                            chunks: [
                                .text("Hello?"),
                                .text("I'm attempting to render some maths now:"),
                                .math(.mathMl(
                    """
                    <mrow>
                    <mi>x</mi>
                    <mo>=</mo>
                    <mfrac>
                    <mrow>
                    <mrow>
                    <mo>−</mo>
                    <mi>b</mi>
                    </mrow>
                    <mo>±</mo>
                    <msqrt>
                    <mrow>
                    <msup>
                    <mi>b</mi>
                    <mn>2</mn>
                    </msup>
                    <mo>−</mo>
                    <mrow>
                    <mn>4</mn>
                    <mo>⁢</mo>
                    <mi>a</mi>
                    <mo>⁢</mo>
                    <mi>c</mi>
                    </mrow>
                    </mrow>
                    </msqrt>
                    </mrow>
                    <mrow>
                    <mn>2</mn>
                    <mo>⁢</mo>
                    <mi>a</mi>
                    </mrow>
                    </mfrac>
                    </mrow>
                    """)),
                                //.text("Here is now Peter Griffen from hit show Family Guy:"),
                                //.image(url: URL(string: "https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png")!, altDescription: "Peter Griffen", decorative: false),
                                    .text("Here is now a dog in the water:"),
                                .image(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/d/d5/Retriever_in_water.jpg")!, altDescription: "Retriever in water", renderMode: .inline),
                                .text("This is the Wikipedia link:"),
                                .text(linkAttributedString)
                            ]
                        ), title: "Debug Preview"
                    )
                } label: {
                    ModuleContentCard(title: "BbMLContentView", description: "Debugging document", action: {})
                }
                .buttonStyle(.plain)

                NavigationLink {
                    BbMLContentViewer(.exampleDocument, title: "Example Document")
                } label: {
                    ModuleContentCard(title: "Example Document", description: "Parser example document from Anthology", action: {})
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Content")
                .font(.title3.bold())
        }
    }

    /*private var optionsMenu: some View {
        Menu {
            optionsMenuContent
        } label: {
            if #available(iOS 26, macOS 26, *) {
                Label("More Options", systemImage: "ellipsis")
            } else {
                Label("More Options", systemImage: "ellipsis.circle")
            }
        }
    }*/

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
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

#Preview(traits: .learnKit) {
    TabView {
        Tab("Module", systemImage: "graduationcap") {
            NavigationStack {
                // Final Year Computing Project
                CourseView(id: "_130430_1")
            }
        }
    }
    .tabViewStyle(.sidebarAdaptable)
}
