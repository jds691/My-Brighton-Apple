//
//  DashboardManualEntryView.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/03/2026.
//

#if DEBUG
import Foundation
import SwiftUI
import SwiftData
import DashboardKit

struct DashboardManualEntryView: View {
    @Environment(\.dashboardService) private var dashboardService

    @State private var dashboardId: DashboardID = DashboardID.yourUpdates
    @State private var selectedEntryType: String? = nil

    @State private var entry: (any DashboardEntry)? = nil

    @State private var showPostError: Bool = false
    @State private var errorText: String = ""

    private var validEntryTypes: Dictionary<String, any DashboardEntry.Type> {
        var entries: Dictionary<String, any DashboardEntry.Type> = [:]
        for category in dashboardId.categories {
            entries.updateValue(Self.extractEntryType(from: category), forKey: category.id)
        }
        return entries
    }

    var body: some View {
        Form {
            Section("Target") {
                Picker("Dashboard ID", selection: $dashboardId) {
                    ForEach(DashboardID.allCases, id: \.rawValue) { dashboardId in
                        Text(dashboardId.rawValue)
                            .tag(dashboardId)
                    }
                }
                .onChange(of: dashboardId) {
                    selectedEntryType = nil
                }

                Picker("Entry Type", selection: $selectedEntryType) {
                    Text("None")
                        .tag(nil as String?)

                    Divider()

                    ForEach(Array(validEntryTypes.keys), id: \.self) { categoryId in
                        Text(String(describing: validEntryTypes[categoryId]!) + " (" + categoryId + ")")
                            .tag(categoryId)
                    }
                }
            }

            Section {
                if selectedEntryType != nil {
                    createViewForSelectedCategory()
                }
            } header: {
                Text("Content")
            } footer: {
                if selectedEntryType == nil {
                    Text("Select an entry type to post.")
                }
            }
        }
        .navigationTitle("Post Manual Entry")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    guard let entry else { return }

                    do throws(DashboardError) {
                        try dashboardService.postEntry(entry, to: dashboardId.rawValue)
                    } catch {
                        switch error {
                            case .dashboardDoesNotExist:
                                errorText = "The dashboard '\(dashboardId.rawValue)' does not exist in the service."
                            case .noValidCategory:
                                errorText = "No category is registered to handle type '\(validEntryTypes[selectedEntryType!]!)'."
                            case .saveFailed:
                                errorText = "SwiftData failed to save the entry."
                            case .invalidInternalConfiguration:
                                errorText = "The internal configuration of the dashboard is invalid. You broke something :P"
                            case .fetchFailed:
                                errorText = "SwiftData failed to fetch a certain type of entry."
                            case .deleteFailed:
                                errorText = "SwiftData failed to delete an entry."
                            case .eraseFailed:
                                errorText = "Erasing a SwiftData ModelContainer failed."
                        }

                        showPostError = true
                    }
                } label: {
                    Text("Post")
                }
            }
        }
        .alert("Failed to post entry", isPresented: $showPostError) {

        } message: {
            Text(errorText)
        }
    }

    @ViewBuilder
    private func createViewForSelectedCategory() -> some View {
        if let selectedEntryType, let entryType = validEntryTypes[selectedEntryType] {
            if entryType === TempEntry.self {
                Group {
                    if let tempEntry = entry as? TempEntry {
                        @Bindable var tempEntry = tempEntry

                        TextField("Idk", text: $tempEntry.idk)
                    } else {
                        Text("Type casting error")
                            .foregroundStyle(.red)
                    }
                }
                .onAppear {
                    entry = TempEntry()
                }
            } else if entryType === ExhibitionWelcomeEntry.self {
                Group {
                    if let exhibitionWelcomeEntry = entry as? ExhibitionWelcomeEntry {
                        @Bindable var exhibitionWelcomeEntry = exhibitionWelcomeEntry

                        TextField("Title", text: $exhibitionWelcomeEntry.title)
                        TextField("Body", text: $exhibitionWelcomeEntry.text)
                    } else {
                        Text("Type casting error")
                            .foregroundStyle(.red)
                    }
                }
                .onAppear {
                    entry = ExhibitionWelcomeEntry()
                }
            }
        } else {
            Text("Cannot render editor")
                .foregroundStyle(.red)
        }
    }

    private static func extractEntryType<C: DashboardKit.Category>(from category: C) -> any DashboardEntry.Type {
        return C.Entry.self
    }
}

#Preview(traits: .dashboardKit) {
    NavigationStack {
        DashboardManualEntryView()
    }
}
#endif
