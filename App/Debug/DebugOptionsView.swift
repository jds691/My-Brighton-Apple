//
//  DebugOptionsView.swift
//  My Brighton
//
//  Created by Neo Salmon on 13/09/2025.
//

#if DEBUG
import SwiftUI
import Router
import WidgetKit
import Timetable
import CoreSpotlight
import LearnKit
import Accounts

struct DebugOptionsView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(Router.self) private var router
    @Environment(SearchManager.self) private var searchManager
    @Environment(\.learnKitService) private var learnKitService
    @Environment(\.timetableService) private var timetableService
    @Environment(\.dashboardService) private var dashboardService
    @Environment(\.accountService) private var accountService

    @AppStorage(TimetableService.remoteURLUserDefaultsKey) private var timetableURL: URL?

    @State private var showIcsImporter: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("DashboardKit") {
                    NavigationLink("Post Manual Entry") {
                        DashboardManualEntryView()
                    }
                }

                Section {
                    Button("Erase all contents") {
                        do {
                            try dashboardService.eraseContent()
                        } catch {

                        }
                    }
                }

                Section("Timetable") {
                    Button("Load iCalendar file") {
                        showIcsImporter = true
                    }
                    Button("Reschedule Class Notifications") {
                        Task {
                            await timetableService.scheduleNotifications(for: .now)
                        }
                    }
                    Button("Reset All") {
                        timetableURL = nil
                        timetableService.clearCalendarCache()
                        timetableService.setRemoteURL(nil)
                    }
                }
                .fileImporter(isPresented: $showIcsImporter, allowedContentTypes: [.calendarEvent]) { result in
                    if case .success(let url) = result {
                        if url.startAccessingSecurityScopedResource() {
                            do {
                                let data = try String(contentsOf: url, encoding: .utf8).data(using: .utf8)!
                                timetableService.reinitialise(with: data)
                            } catch {
                                print(error)
                            }
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                }

                Section {
                    Button("Refresh Widget") {
                        WidgetCenter.shared.reloadTimelines(ofKind: "TimetableWidget")
                    }
                }

                Section("Search") {
                    Button("Prefill Search Test") {
                        dismiss()
                        router.navigate(to: .route(.search))
                        searchManager.search(for: "Test")
                    }

                    Button("Erase Spotlight Contents") {
                        CSSearchableIndex.default().deleteAllSearchableItems()
                    }
                }

                Section("Accounts") {
                    Button("Mark authentication as expired") {
                        accountService.markAuthenticationExpired()
                    }

                    Button("Clear authentication") {
                        accountService.clearAuthenticatedAccount()
                    }
                }
            }
            .navigationTitle("Debug")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26, macOS 26, *) {
                        Button(role: .close) {
                            dismiss()
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                        }
                    }
                }
            }
            #if os(macOS)
            .scenePadding()
            #endif
        }
    }
}

#Preview(traits: .environmentObjects, .learnKit, .timetableService, .dashboardKit) {
    DebugOptionsView()
}
#endif
