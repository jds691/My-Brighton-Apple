//
//  AnnouncementsView.swift
//  My Brighton
//
//  Created by Neo Salmon on 12/08/2025.
//

import SwiftUI
import Router

struct ModuleAnnouncementsScrollView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.announcements) {
                HStack {
                    Text("Recent Announcements")
                        .font(.title3.bold())
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.brightonSecondary)
                        .imageScale(.large)
                }
            }
            .buttonStyle(.plain)

            // According to Apple the scroll view has to be touching the sidebar for it to count
            // Padding it else where might be causing problems?
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(1...10, id: \.self) { _ in
                        ModuleAnnouncementCard()
                            .containerRelativeFrame([.horizontal], count: 5, span: containerFrameSpan, spacing: 8)
                    }
                }
                .fixedSize()
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
        .scrollClipDisabled()
    }

    private var containerFrameSpan: Int {
        hSizeClass == .compact ? 5 : 2
    }
}

#Preview {
    ModuleAnnouncementsScrollView()
        .scenePadding()
        .scrollClipDisabled()
}
