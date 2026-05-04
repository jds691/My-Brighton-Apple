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
    private var backgroundCardStyle: Self.BackgroundCardStyle

    private var paddedEdges: Edge.Set = []
    private var paddingAmount: CGFloat? = nil

    public init(for dashboard: Dashboard) {
        self.dashboard = dashboard
        self.backgroundCardStyle = .standard
    }

    public var body: some View {
        if !dashboard.entries.isEmpty {
            ScrollView(.horizontal) {
                if backgroundCardStyle == .clear, #available(iOS 26, macOS 26, *) {
                    GlassEffectContainer {
                        LazyHStack(alignment: .top) {
                            cards
                        }
                        .fixedSize()
                        .scrollTargetLayout()
                    }
                } else {
                    LazyHStack(alignment: .top) {
                        cards
                    }
                    .fixedSize()
                    .scrollTargetLayout()
                }
            }
            .contentMargins(paddedEdges, paddingAmount, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        } else {
            NoContentView("No Recent Updates")
                .frame(height: 80)
                .padding(paddedEdges, paddingAmount)
        }
    }

    @ViewBuilder
    private var cards: some View {
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
                .modifier(DashboardCarousellCardBackgroundModifier(backgroundCardStyle))
                // Entry extension view modifiers
                .modifier(NavigableEntryViewModifier(entry))
#if DEBUG
                Group {
                    Text("Entry type: \(String(reflecting: entry))")
                    if let category = dashboard.getCategory(for: entry) {
                        Text("Category ID: \(category.id)")
                    } else {
                        Text("Category ID: (nil)")
                    }
                    Text("  ")
                    if let navigableEntry = entry as? (any NavigableEntry) {
                        Text("NavigableEntry: YES")
                        Text("  navigationPoint: \(String(describing: navigableEntry.navigationPoint))")
                    } else {
                        Text("  NavigableEntry: NO")
                    }
                }
                .accessibilityHidden(true)
                .font(.caption.monospaced())

                if let category = dashboard.getCategory(for: entry) {
                    Button("Delete") {
                        do {
                            try dashboard.deleteEntry(by: entry.id, for: DashboardService.extractEntryType(from: category))
                        } catch {

                        }
                    }
                    .accessibilityHidden(true)
                }
#endif
            }
            .accessibilityElement(children: .combine)
            .containerRelativeFrame([.horizontal], count: 5, span: containerFrameSpan, spacing: 0)
        }
    }

    private var containerFrameSpan: Int {
        hSizeClass == .compact ? 5 : 2
    }

    private func anyToSomeEntry<E: DashboardEntry>(_ entry: E) -> some DashboardEntry {
        return entry
    }

    @ViewBuilder
    private func getEntryView<T: Category, E: DashboardEntry>(for category: T, dashboard: Dashboard, entry: E) -> some View {
        category.content(dashboard: dashboard, entry: entry as! T.Entry)
    }

    public enum BackgroundCardStyle {
        case standard
        case clear
    }
}

extension DashboardCarousell {
    public func carousellPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> Self {
        var view = self
        view.paddedEdges = edges
        view.paddingAmount = length

        return view
    }
}

extension DashboardCarousell {
    public func cardBackgroundStyle(_ style: BackgroundCardStyle) -> Self {
        var view = self

        view.backgroundCardStyle = style
        return view
    }
}
