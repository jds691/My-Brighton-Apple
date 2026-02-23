//
//  AnnouncementView.swift
//  My Brighton
//
//  Created by Neo Salmon on 19/02/2026.
//

import Foundation
import SwiftUI
import LearnKit
import SwiftBbML

struct AnnouncementView: View {
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    var announcement: any Announcement
    private var hideDismissButton: Bool = false
    private var headerUsesSystemLocation: Bool = false

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
                        if !headerUsesSystemLocation {
                            header
                        }
                        BbMLView(bbML)
                    }
                    .contentMargins(16, for: .scrollContent)
                } else {
                    ProgressView()
                }
            }
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
        .modifierBranch {
            if headerUsesSystemLocation {
                if #available(iOS 26, macOS 11, *) {
                    $0
                        .navigationTitle(announcement.title)
                        .navigationSubtitle(dateAndTime)
                } else {
                    $0
                        .navigationTitle(announcement.title)
                }
            } else {
                $0
            }
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
            Text("Unable to parse announcement content. Try viewing this content on the My Studies website.")
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading) {
            Text(announcement.title)
                .font(.largeTitle.bold())
            Text(verbatim: dateAndTime)
                .lineLimit(1)
                .font(.caption2)
                .foregroundStyle(.brightonSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    enum HeaderLocation: Hashable, Sendable {
        case inline
        case navigationBar
    }
}

extension AnnouncementView {
    func hidesDismissButton(_ hide: Bool = true) -> Self {
        var view = self
        view.hideDismissButton = hide

        return view
    }

    func headerLocation(_ location: HeaderLocation) -> Self {
        var view = self
        view.headerUsesSystemLocation = location == .navigationBar

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
