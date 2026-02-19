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
    @Binding var announcements: [any Announcement]?

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

            if let announcements {
                if !announcements.isEmpty {
                    // According to Apple the scroll view has to be touching the sidebar for it to count
                    // Padding it else where might be causing problems?
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(announcements, id: \.id) { announcement in
                                ModuleAnnouncementCard(announcement: announcement)
                                    .containerRelativeFrame([.horizontal], count: 5, span: containerFrameSpan, spacing: 8)
                            }
                        }
                        .fixedSize()
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                } else {
                    NoContentView("No Recent Announcements")
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
                    .background(.brightonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .strokeBorder(lineWidth: 3, antialiased: true)
                    }
            }
        }
        .scrollClipDisabled()
    }

    private var containerFrameSpan: Int {
        hSizeClass == .compact ? 5 : 2
    }
}

#Preview {
    ModuleAnnouncementsScrollView(announcements: .constant([]))
        .scenePadding()
        .scrollClipDisabled()
}
