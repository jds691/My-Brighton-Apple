//
//  HomeView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import MapKit
import LearnKit
import AuthenticationServices
import Router
import CoreDesign
import DashboardKit
import CustomisationKit

struct HomeView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    let studentViewURL = URL(string: "https://studentview.brighton.ac.uk/")!
    let wellbeingURL = URL(string: "https://www.brighton.ac.uk/brighton-students/your-student-life/my-wellbeing/index.aspx")!
    let careersURL = URL(string: "https://careersconnect.brighton.ac.uk/")!

    @Namespace var headerID

    @Environment(\.openURL) private var openURL
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @Environment(\.dashboardService) private var dashboardService
    @Environment(Router.self) private var router
    @Environment(SearchManager.self) private var searchManager: SearchManager
    @Environment(\.learnKitService) private var learnKitService

    @State private var scrollPosition: CGPoint = .zero
    @State private var showTitle: Bool = false

    @State private var showInboxView: Bool = false
    @State private var showStudentView: Bool = false
    @State private var showYourWellbeing: Bool = false
    @State private var showCareers: Bool = false

    @State private var showSignOut: Bool = false

    @State private var homeCustomisations: HomeCustomisation = HomeCustomisation()

    @State private var showCustomisationEditor: Bool = false

    #if DEBUG
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        let importantDashboard = dashboardService.getDashboard(for: DashboardID.importantUpdates.rawValue)

        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HomeHeaderView(customisations: $homeCustomisations, opaqueBlur: importantDashboard != nil && !importantDashboard!.entries.isEmpty)
                        .flexibleHeaderContent()
                        .modifier(ShowHomeCustomisationEditViewModifier(customisations: $homeCustomisations, showEditor: $showCustomisationEditor))
                        .id(headerID)
                    if let importantDashboard, !importantDashboard.entries.isEmpty {
                        HomeImportantUpdatesCarousell(dashboard: importantDashboard, customisations: homeCustomisations)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        if let dashboard = dashboardService.getDashboard(for: DashboardID.yourUpdates.rawValue) {
                            Text("Your Updates")
                                .font(.title3.bold())
                                .padding(.horizontal, 16)
                                .accessibilityAddTraits(.isHeader)

                            DashboardCarousell(for: dashboard)
                                .carousellPadding(.horizontal, 16)
                                //.padding(.horizontal, 16)
                                //.padding(.horizontal, -16)
                                //.contentMargins(.horizontal, 16, for: .scrollContent)
                        }
                    }
                    SplitStack(
                        horizontalAlignment: .leading,
                        splitSpacing: 16
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            TimetableHomeWidgetView()
                                .padding(hSizeClass == .compact ? .horizontal : .leading, 16)
                            UpcomingAssignmentsHomeWidgetView()
                        }
                    } secondaryContent: {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Services")
                                    .font(.title3.bold())
                                    .accessibilityAddTraits(.isHeader)

                                HomeResourceButton {
#if os(iOS)
                                    if #available(iOS 26, *) {
                                        openURL(studentViewURL, prefersInApp: true)
                                    } else {
                                        showStudentView = true
                                    }
#else
                                    openURL(studentViewURL)
#endif
                                } label: {
                                    Label("Student View", systemImage: "person")
                                }
                                HomeResourceButton {
#if os(iOS)
                                    if #available(iOS 26, *) {
                                        openURL(careersURL, prefersInApp: true)
                                    } else {
                                        showCareers = true
                                    }
#else
                                    openURL(careersURL)
#endif
                                } label: {
                                    Label("Careers", systemImage: "briefcase")
                                }
                            }

                            VStack(alignment: .leading) {
                                Text("Resources")
                                    .font(.title3.bold())
                                    .accessibilityAddTraits(.isHeader)

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/StudentLife.aspx")!) {
                                    Text(":) Student Life")
                                }

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/Support.aspx")!) {
                                    Label("Support", systemImage: "lifepreserver")
                                }

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/Studies.aspx")!) {
                                    Label("Studies", systemImage: "graduationcap")
                                }

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/Library.aspx")!) {
                                    Label("Library", systemImage: "books.vertical")
                                }

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/IT.aspx")!) {
                                    Label("IT", systemImage: "desktopcomputer")
                                }

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/Getting-around.aspx")!) {
                                    Label("Campus and Travel", systemImage: "figure.run")
                                }

                                HomeResourceButton(url: URL(string: "https://unibrightonac.sharepoint.com/SitePages/Getting-around.aspx")!) {
                                    Label("Belong at Brighton", image: "uni.logo")
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .scrollClipDisabled()
                .disabled(showCustomisationEditor)
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
            .ignoresSafeArea(edges: .top)
            .scrollDisabled(showCustomisationEditor)
#if os(iOS)
            .statusBarHidden(showCustomisationEditor)
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
            .modifierBranch {
                if #available(iOS 26, macOS 26, *) {
                    $0
                        .toolbar {
                            ToolbarItem(placement: .title) {
                                if showTitle {
                                    Text("Home")
                                        .lineLimit(1)
                                } else {
                                    Text("")
                                }
                            }
                        }
                } else {
                    $0
                        .toolbar(showTitle ? .visible : .hidden, for: .navigationBar)
                        .legacyToolbar(visible: !showTitle, showBackButton: false) {
                            if !showCustomisationEditor {
                                primaryMenu(proxy)
                            }
                        }
                }
            }
#endif
            .myBrightonBackground()
            .navigationTitle("Home")
            .navigationDestination(for: Navigation.Route.HomeSubRoute.self) { subroute in
                switch subroute {
                    case .timetable(let initialDate):
                        TimetableView(initialDate: initialDate)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if !showCustomisationEditor {
                        primaryMenu(proxy)
                    }
                }
            }
#if os(iOS)
            .sheet(isPresented: $showStudentView) {
                SafariView(url: studentViewURL)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showYourWellbeing) {
                SafariView(url: wellbeingURL)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showCareers) {
                SafariView(url: careersURL)
                    .ignoresSafeArea()
            }
            .toolbarVisibility(showCustomisationEditor ? .hidden : .automatic, for: .tabBar)
#endif
#if DEBUG
            .sheet(isPresented: $showDebugView) {
                DebugOptionsView()
            }
#endif
            .onAppear {
                homeCustomisations = CustomisationService.shared.getHomeCustomisation()
            }
        }
    }

    //MARK: Localisation
    private let signOutMessage: String = .init(
        localized: "SIGN_OUT_MESSAGE",
        defaultValue: "You'll need to sign back in to use My Brighton. Your UniCard will also be removed from Apple Wallet and Automatic Top-Up via Apple Pay will be cancelled.",
        table: "Account",
        comment: "Shown in an alert when the user signs out. Signing out removes their student ID from Apple Wallet and disables auto top-up if it is set up via Apple Pay."
    )

    @ViewBuilder
    private func primaryMenu(_ proxy: ScrollViewProxy) -> some View {
        Menu {
            Button {

            } label: {
                Label("Edit Sections", systemImage: "checklist")
            }

            Button {
                withAnimation {
                    proxy.scrollTo(headerID, anchor: .top)
                    showCustomisationEditor = true
                }
            } label: {
                Label("Customise", systemImage: "paintbrush")
            }

            Divider()

            Button {
                router.navigate(to: .modal(.account))
            } label: {
                Label("Settings", systemImage: "gear")
            }

            Divider()

            Button {

            } label: {
                Label("Send Feedback", systemImage: "bubble.and.pencil")
            }

            Button(role: .destructive) {
                showSignOut = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward")
            }

#if DEBUG
            Divider()

            Button {
                showDebugView = true
            } label: {
                Label("Debug", systemImage: "wrench")
            }
#endif
        } label: {
            if #available(iOS 26, macOS 26, *) {
                Label("More Options", systemImage: "ellipsis")
            } else {
                Label("More Options", systemImage: "ellipsis.circle")
            }
        }
        .confirmationDialog("Sign Out", isPresented: $showSignOut) {
            Button(role: .destructive) {
            } label: {
                Text("Sign Out")
            }
        } message: {
            Text(signOutMessage)
        }
    }
}

#Preview(traits: .environmentObjects, .learnKit, .timetableService, .customisationKit) {
    NavigationStack {
        HomeView()
    }
}
