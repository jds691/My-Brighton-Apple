//
//  AnnouncementWindowView.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/02/2026.
//

import Foundation
import SwiftUI
import LearnKit

struct AnnouncementWindowView: View {
    @Environment(\.dismissWindow) private var dismiss
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.courseId) private var courseId

    var announcementId: String

    @State private var announcement: (any Announcement)? = nil
    @State private var showLoadFailedMessage: Bool = false
    @State private var loadFailedMessage: String = ""

    init(sAnnouncementId: SystemAnnouncement.ID) {
        self.announcementId = sAnnouncementId
    }

    init(cAnnouncementId: CourseAnnouncement.ID) {
        self.announcementId = cAnnouncementId
    }

    var body: some View {
        Group {
            if let announcement {
                AnnouncementView(announcement: announcement, onDismiss: { dismiss() })
                    .hidesDismissButton()
            } else {
                ProgressView()
            }
        }
        .alert("Unable to load announcement", isPresented: $showLoadFailedMessage) {
            Button("OK") {
                showLoadFailedMessage = false
                dismiss()
            }
        } message: {
            Text(loadFailedMessage)
        }
        .task {
            do {
                if let courseId {
                    announcement = try await learnKit.getCourseAnnouncement(for: announcementId, in: courseId)
                } else {
                    announcement = try await learnKit.getSystemAnnouncement(for: announcementId)
                }
            } catch {
                loadFailedMessage = "There was a problem loading this announcement. Try checking the Blackboard website."
                showLoadFailedMessage = true
            }

            if announcement == nil {
                loadFailedMessage = "The announcement could not be found. Try checking the Blackboard website."
                showLoadFailedMessage = true
            }
        }
    }
}
