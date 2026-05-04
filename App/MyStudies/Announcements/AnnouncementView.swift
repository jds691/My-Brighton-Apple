//
//  AnnouncementView.swift
//  My Brighton
//
//  Created by Neo Salmon on 19/02/2026.
//

import Foundation
import SwiftUI
import AppIntents
import LearnKit
import CoreDesign
import SwiftBbML
import Router

struct AnnouncementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.courseId) private var courseId

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    var announcement: any Announcement
    private var hideDismissButton: Bool = false

    @State private var bbML: BbMLContent? = nil
    @State private var showLoadFailedMessage: Bool = false

    @State private var viewDismissAction: (() -> Void)?

    private var dateAndTime: String {
        if announcement.creationDate != announcement.lastModifiedDate {
            dateFormatter.string(from: announcement.creationDate) + " (Last edited: \(dateFormatter.string(from: announcement.lastModifiedDate)))"
        } else {
            dateFormatter.string(from: announcement.creationDate)
        }
    }

    init(announcement: any Announcement, onDismiss: (() -> Void)? = nil) {
        self.announcement = announcement
        self.viewDismissAction = onDismiss
    }

    var body: some View {
        NavigationStack {
            Group {
                if let bbML {
                    ScrollView(.vertical) {
                        BbMLView(bbML)
                    }
                    .contentMargins(16, for: .scrollContent)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .modifierBranch {
                        if #available(iOS 26, macOS 11, *) {
                            $0
                                .navigationTitle(announcement.title)
                                .navigationSubtitle(dateAndTime)
                        } else {
                            $0
                                .navigationTitle(announcement.title)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .myBrightonBackground()
            .toolbar {
                if !hideDismissButton {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark")
                        }
                        .labelStyle(.designSystemAware)
                    }
                }
            }
        }
        .userActivity(UserActivity.MyStudies.Course.Announcement.view) {
            $0.title = "Viewing announcement '\(announcement.title)'"
            if let courseId {
                $0.targetContentIdentifier = "announcementID=\(announcement.id)&courseID=\(courseId)"
                $0.userInfo = [
                    "announcementID": announcement.id,
                    "courseID": courseId
                ]
                if #available(iOS 18.2, macOS 15.2, *) {
                    $0.appEntityIdentifier = EntityIdentifier(for: CourseAnnouncementEntity.self, identifier: "\(courseId)/\(announcement.id)")
                }
            } else {
                $0.targetContentIdentifier = "announcementID=\(announcement.id)"
                $0.userInfo = [
                    "announcementID": announcement.id
                ]
            }
            $0.isEligibleForHandoff = true
            $0.requiredUserInfoKeys = ["announcementID"]
        }
        .onAppear {
            if viewDismissAction == nil {
                viewDismissAction = { dismiss() }
            }

            do {
                bbML = try BbMLParser.default.parse(announcement.body)
            } catch {
                showLoadFailedMessage = true
            }
        }
        .alert("Unable to load announcement", isPresented: $showLoadFailedMessage) {
            Button("OK") {
                showLoadFailedMessage = false
                // Should never actually be a problem but what if
                (viewDismissAction ?? dismiss.callAsFunction)()
            }
        } message: {
            Text("Unable to parse announcement content. Try viewing this content on the Blackboard website.")
        }
    }
}

extension AnnouncementView {
    func hidesDismissButton(_ hide: Bool = true) -> Self {
        var view = self
        view.hideDismissButton = hide

        return view
    }
}

#Preview {
    AnnouncementView(
        announcement: PreviewAnnouncement(
            id: "_0_1",
            title: "Preview",
            body: "<p>Preview body.</p>",
            creationDate: .now,
            lastModifiedDate: .now,
            position: 0,
            creatorId: "_0_1"
        )
    )
}
