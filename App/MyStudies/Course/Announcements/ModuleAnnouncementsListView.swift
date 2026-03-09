//
//  ModuleAnnouncementsView.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/02/2026.
//

import Foundation
import SwiftUI
import LearnKit
import Router

struct ModuleAnnouncementsListView: View {
    @Environment(\.courseId) private var courseId
    @Environment(\.dismiss) private var dismiss
    @Environment(\.learnKitService) private var learnKit

    @State private var announcements: [any Announcement]?

    @State private var showLoadFailedMessage: Bool = false

    private var initialAnnouncementIdToShow: CourseAnnouncement.ID?
    private var onAnnouncementTapped: (any Announcement) -> Void

    init(initialAnnouncementId: CourseAnnouncement.ID? = nil, onAnnouncementTapped: @escaping (any Announcement) -> Void) {
        self.initialAnnouncementIdToShow = initialAnnouncementId
        self.onAnnouncementTapped = onAnnouncementTapped
    }

    var body: some View {
        Group {
            if let announcements {
                ScrollView(.vertical) {
                    ForEach(announcements, id: \.id) { announcement in
                        ModuleAnnouncementCard(announcement: announcement)
                            .onTapGesture { onAnnouncementTapped(announcement) }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .contentMargins(16, for: .scrollContent)
        .myBrightonBackground()
        .navigationTitle("Announcements")
        .task {
            guard let courseId else { dismiss(); return }

            do {
                try await learnKit.refreshCourseAnnouncements(for: courseId)
                announcements = try await learnKit.getAllCourseAnnouncements(for: courseId)
            } catch {
                dismiss()
            }

            if announcements == nil {
                dismiss()
            } else if let initialAnnouncementIdToShow, let announcement = announcements?.first(where: { $0.id == initialAnnouncementIdToShow }) {
                // TODO: Doesn't seem to be correctly triggered
                onAnnouncementTapped(announcement)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModuleAnnouncementsListView(onAnnouncementTapped: {_ in })
    }
    .environment(\.courseId, "_0_1")
}
