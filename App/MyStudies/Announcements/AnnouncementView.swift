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

    @State private var bbML: BbMLContent? = nil

    private var dateAndTime: String {
        if announcement.creationDate != announcement.lastModifiedDate {
            dateFormatter.string(from: announcement.creationDate) + " (Last edited: \(dateFormatter.string(from: announcement.lastModifiedDate)))"
        } else {
            dateFormatter.string(from: announcement.creationDate)
        }
    }

    init(announcement: any Announcement) {
        self.announcement = announcement
    }

    var body: some View {
        NavigationStack {
            Group {
                if let bbML {
                    ScrollView(.vertical) {
                        header
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
        .onAppear {
            do {
                bbML = try BbMLParser.default.parse(announcement.body)
            } catch {

            }
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
