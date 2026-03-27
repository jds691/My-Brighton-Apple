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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Post") {

                }
            }
        }
    }

    @ViewBuilder
    private func createViewForSelectedCategory() -> some View {
        if let selectedEntryType, let entryType = validEntryTypes[selectedEntryType] {
            if entryType === TempEntry.self {
                Text("Eh")
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
