//
//  MyBrightonApp.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import AppIntents
import SwiftUI
import CoreSpotlight
import LearnKit
import Timetable
import UserNotifications
import Router
import Notifier
import DashboardKit
#if os(macOS)
import ServiceManagement
#endif

@main
struct MyBrightonApp: App {
    // As it turns out, Apple changed how some APIs work. It doesn't seem possible to seperate instances between windows anymore
    // So 2 windows on iPadOS will *always* point to the same location even if the current nav destination is changed between differetn windows
    @State private var searchManager: SearchManager = SearchManager.shared
    @State private var router: Router
    private let notifier: Notifier
    private let dashboardService: DashboardService
    private let learnKitService: LearnKitService
    private let timetableService: TimetableService

    private let defaultAppStorage: UserDefaults = UserDefaults(suiteName: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton")!

#if os(iOS)
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) private var delegateAdaptor
#endif
    
    init() {
        let appRouter = Router.shared
        // Has to be like this because for some reason self.notifier must be initialised first
        self.dashboardService = DashboardService {}
        self.notifier = Notifier(router: appRouter)
        self.router = appRouter

        self.learnKitService = LearnKitService(client: PreviewClient())
        //self.learnKitService = LearnKitService(learnInstanceURL: try! Servers.Server1.url())
        self.timetableService = TimetableService(notifier: self.notifier)


        // Taken from sample code, idk why it's like this but I shall accept it
        let appSearchManager = self.searchManager
        let appLearnKitService = self.learnKitService
        let appTimetableService = self.timetableService

        UNUserNotificationCenter.current().delegate = self.notifier

        AppDependencyManager.shared.add(dependency: appRouter)
        AppDependencyManager.shared.add(dependency: appSearchManager)
        AppDependencyManager.shared.add(dependency: appLearnKitService)
        AppDependencyManager.shared.add(dependency: appTimetableService)

        MyBrightonAppShortcuts.updateAppShortcutParameters()
        
#if os(iOS)
        // App is @MainActor annotated, will always run on MainActor
        // Safe to call it like this as version info is not directly required up front and no additional settings are written to the bundle
        SettingsBundleService.shared.setVersionInfo()
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
                .environment(\.dashboardService, dashboardService)
            #if os(macOS)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
            #endif
                .task {
                    await notifier.requestAuthorisation()
                }
                .onAppear {
                    timetableService.scheduleRefresh()
                }
                .handlesExternalEvents(preferring: [], allowing: ["*"])
        }
        .defaultAppStorage(defaultAppStorage)
        .handlesExternalEvents(matching: ["*"])
        .commands {
            SidebarCommands()
            TextEditingCommands()
            ToolbarCommands()
            #if os(macOS)
            ImportFromDevicesCommands()
            #endif

            AccountCommands()
            CourseCommands()
        }
        #if !os(macOS)
        .backgroundTask(.appRefresh("com.neo.My-Brighton.Timetable.refresh")) {
            do {
                try await timetableService.refresh()
            } catch {
                print("Failed to refresh timetable service")
            }
        }
        #endif

        WindowGroup(id: "module", for: Course.ID.self) { $id in
            Group {
                if let id = $id.wrappedValue {
                    NavigationStack {
                        CourseView(id: id)
                    }
                } else {
                    ContentUnavailableView("¯\\_(ツ)_/¯", systemImage: "xmark")
                }
            }
            .environment(router)
            .environment(searchManager)
            .environment(\.learnKitService, learnKitService)
            .environment(\.timetableService, timetableService)
            .environment(\.dashboardService, dashboardService)
#if os(macOS)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
            }
#endif
            .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultAppStorage(defaultAppStorage)
        .handlesExternalEvents(matching: [])

        #if os(macOS)
        Settings {
            AccountView()
                .scenePadding()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
                .environment(\.dashboardService, dashboardService)
                .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultAppStorage(defaultAppStorage)
        .handlesExternalEvents(matching: [])

        WindowGroup(id: "course-announcement", for: CourseAnnouncementIDUnion.self) { $idUnion in
            Group {
                if let idUnion = $idUnion.wrappedValue {
                    AnnouncementWindowView(cAnnouncementId: idUnion.announcementId)
                        .environment(\.courseId, idUnion.courseId)
                } else {
                    ContentUnavailableView("¯\\_(ツ)_/¯", systemImage: "xmark")
                }
            }
            .environment(router)
            .environment(searchManager)
            .environment(\.learnKitService, learnKitService)
            .environment(\.timetableService, timetableService)
            .environment(\.dashboardService, dashboardService)
            .containerBackground(.brightonBackground, for: .window)
            .toolbarBackground(.hidden, for: .windowToolbar)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
            }
        }
        .defaultAppStorage(defaultAppStorage)

        Window("Timetable", id: "timetable") {
            TimetableView()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
                .environment(\.dashboardService, dashboardService)
                .handlesExternalEvents(preferring: ["timetable="], allowing: ["timetable="])
        }
        .windowResizability(.contentSize)
        .defaultAppStorage(defaultAppStorage)
        .handlesExternalEvents(matching: ["timetable="])
        #endif
    }
}
