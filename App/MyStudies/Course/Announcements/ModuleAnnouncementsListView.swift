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

    var body: some View {
        Group {
            if let announcements {
                ScrollView(.vertical) {
                    ForEach(announcements, id: \.id) { announcement in
                        ModuleAnnouncementCard(announcement: announcement)
                            .onTapGesture {

                            }
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
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModuleAnnouncementsListView()
    }
    .environment(\.courseId, "_0_1")
}
