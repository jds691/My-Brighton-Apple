//
//  DashboardCarousell.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

import SwiftUI
import CoreDesign
import SwiftData

public struct DashboardCarousell: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let dashboard: Dashboard

    public init(for dashboard: Dashboard) {
        self.dashboard = dashboard
    }

    public var body: some View {
        if !dashboard.entries.isEmpty {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(dashboard.entries, id: \.persistentModelID) { entry in
                        VStack(alignment: .leading) {
                            Group {
                                if let category = dashboard.getCategory(for: entry) {
                                    AnyView(getEntryView(for: category, dashboard: dashboard, entry: entry))
                                } else {
                                    Text("FUCK")
                                        .foregroundStyle(.red)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
                            .padding(16)
                            .background(.brightonBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .circular)
                                    .strokeBorder(lineWidth: 3, antialiased: true)
                            }
                            #if DEBUG
                            Text("Entry type: \(String(reflecting: entry))")
                            if let category = dashboard.getCategory(for: entry) {
                                Text("Category ID: \(category.id)")
                            } else {
                                Text("Category ID: (nil)")
                            }
                            #endif
                        }
                        .containerRelativeFrame([.horizontal], count: 5, span: containerFrameSpan, spacing: 8)
                    }
                }
                .fixedSize()
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        } else {
            NoContentView("No Recent Updates")
                .frame(height: 80)
        }
    }

    private var containerFrameSpan: Int {
        hSizeClass == .compact ? 5 : 2
    }

    @ViewBuilder
    private func getEntryView<T: Category, E: DashboardEntry>(for category: T, dashboard: Dashboard, entry: E) -> some View {
        category.content(dashboard: dashboard, entry: entry as! T.Entry)
    }
}
