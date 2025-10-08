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

struct DebugOptionsView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @Environment(\.dismiss) private var dismiss

    @Environment(Router.self) private var router
    @Environment(SearchManager.self) private var searchManager
    @Environment(\.learnKitService) private var learnKitService
    @Environment(\.timetableService) private var timetableService

    @AppStorage(TimetableService.remoteURLUserDefaultsKey) private var timetableURL: URL?

    @State private var showIcsImporter: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Accounts") {
                    Button("LearnKit Auth") {
                        Task {
                            try? await learnKitService.authenticateUser(using: webAuthenticationSession)
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

                    Button("Create fake Spotlight data") {
                        Task {
                            await fakeSpotlightData()
                        }
                    }

                    Button("Erase Spotlight Contents") {
                        CSSearchableIndex.default().deleteAllSearchableItems()
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
        }
    }

    private func fakeSpotlightData() async {
        let exampleCourseAttributes = CSSearchableItemAttributeSet()
        exampleCourseAttributes.title = "Integrated Group Project"
        exampleCourseAttributes.contentDescription = "CI536"
        #if os(iOS)
        exampleCourseAttributes.thumbnailData = UIImage(named: "Thumbnails/nature14_thumb")?.pngData()
        #else
        exampleCourseAttributes.thumbnailData = NSImage(named: "Thumbnails/nature14_thumb")?.tiffRepresentation
        #endif

        let exampleCourseItem = CSSearchableItem(uniqueIdentifier: "course/\(3)", domainIdentifier: nil, attributeSet: exampleCourseAttributes)
        exampleCourseItem.associateAppEntity(CourseEntity(id: "3", name: "Integrated Group Project", imageName: "Thumbnails/nature14_thumb"))

        do {
            try await CSSearchableIndex.default().indexSearchableItems([exampleCourseItem])
            print("Indexed example info")
        } catch {
            print(error)
        }
    }
}

#Preview(traits: .environmentObjects, .learnKit, .timetableService) {
    DebugOptionsView()
}
#endif
