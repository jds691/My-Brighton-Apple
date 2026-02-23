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
#if os(macOS)
import ServiceManagement
#endif

@main
struct MyBrightonApp: App {
    // As it turns out, Apple changed how some APIs work. It doesn't seem possible to seperate instances between windows anymore
    // So 2 windows on iPadOS will *always* point to the same location even if the current nav destination is changed between differetn windows
    @State private var searchManager: SearchManager = SearchManager.shared
    @State private var router: Router = Router.shared
    private let learnKitService: LearnKitService
    private let timetableService: TimetableService

#if os(iOS)
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) private var delegateAdaptor
#endif
    
    init() {
        self.learnKitService = LearnKitService(client: PreviewClient())
        //self.learnKitService = LearnKitService(learnInstanceURL: try! Servers.Server1.url())
        self.timetableService = TimetableService()

        // Taken from sample code, idk why it's like this but I shall accept it
        let appRouter = self.router
        let appSearchManager = self.searchManager
        let appLearnKitService = self.learnKitService
        let appTimetableService = self.timetableService

        AppDependencyManager.shared.add(dependency: appRouter)
        AppDependencyManager.shared.add(dependency: appSearchManager)
        AppDependencyManager.shared.add(dependency: appLearnKitService)
        AppDependencyManager.shared.add(dependency: appTimetableService)

        MyBrightonAppShortcuts.updateAppShortcutParameters()
        
#if os(iOS)
        // App is @MainActor annotated, will always run on MainActor
        // Safe to call it like this as version info is not directly required up front and no additional settings are written to the bundle
        SettingsBundleService.shared.setVersionInfo()

        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Avenir-Heavy", size: 34)!]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Avenir-Heavy", size: 17)!]

        UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont(name: "Avenir-Medium", size: 10)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont(name: "Avenir-Heavy", size: 10)!], for: .selected)
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
            #if os(macOS)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
            #endif
                .task {
                    do {
                        let authorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert, .carPlay, .providesAppNotificationSettings])
                    } catch {
                        
                    }
                }
                .onAppear {
                    timetableService.scheduleRefresh()
                }
                .handlesExternalEvents(preferring: [], allowing: ["*"])
        }
        .defaultAppStorage(UserDefaults(suiteName: "group.com.neo.My-Brighton")!)
        .handlesExternalEvents(matching: ["*"])
        .commands {
            SidebarCommands()
            TextEditingCommands()
            ToolbarCommands()
            #if os(macOS)
            ImportFromDevicesCommands()
            #endif

            AccountCommands()
            ContentCommands()
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

        WindowGroup(id: "module", for: Module.ID.self) { $id in
            Group {
                if let id = $id.wrappedValue {
                    NavigationStack {
                        CourseView(id: id)
                    }
                } else {
                    ContentUnavailableView("¯\\_(ツ)_/¯", systemImage: "xmark")
                }
            }
#if os(macOS)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
            }
#endif
            .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultAppStorage(UserDefaults(suiteName: "group.com.neo.My-Brighton")!)
        .handlesExternalEvents(matching: [])

        #if os(macOS)
        Settings {
            AccountView()
                .scenePadding()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
                .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultAppStorage(UserDefaults(suiteName: "group.com.neo.My-Brighton")!)
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
            .containerBackground(.brightonBackground, for: .window)
            .toolbarBackground(.hidden, for: .windowToolbar)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
            }
        }
        .defaultAppStorage(UserDefaults(suiteName: "group.com.neo.My-Brighton")!)

        Window("Inbox", id: Modal.inbox.windowId) {
            InboxView()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
                .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultAppStorage(UserDefaults(suiteName: "group.com.neo.My-Brighton")!)
        .handlesExternalEvents(matching: [])

        Window("Timetable", id: "timetable") {
            TimetableView()
                .environment(router)
                .environment(searchManager)
                .environment(\.learnKitService, learnKitService)
                .environment(\.timetableService, timetableService)
                .handlesExternalEvents(preferring: ["timetable="], allowing: ["timetable="])
        }
        .windowResizability(.contentSize)
        .defaultAppStorage(UserDefaults(suiteName: "group.com.neo.My-Brighton")!)
        .handlesExternalEvents(matching: ["timetable="])
        #endif
    }
}
