//
//  ModuleAnnouncementView.swift
//  My Brighton
//
//  Created by Neo Salmon on 09/08/2025.
//

import Foundation
import SwiftBbML
import SwiftUI
import LearnKit
import CoreDesign

struct ModuleAnnouncementCard: View {
    private var title: String
    private var bodyText: String
    private var createdAt: Date
    private var editedAt: Date

    private var markAsReadAction: (() -> Void)?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()

    init(title: String, bodyText: String, createdAt: Date, editedAt: Date) {
        self.title = title
        self.bodyText = bodyText
        self.createdAt = createdAt
        self.editedAt = editedAt
    }

    init(announcement: some Announcement) {
        self.title = announcement.title
        self.bodyText = announcement.body
        self.createdAt = announcement.creationDate
        self.editedAt = announcement.lastModifiedDate
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            if let bbML = try? BbMLParser.default.parse(bodyText), let summary = createCardSummary(bbML) {
                if !summary.isEmpty {
                    Text(summary)
                        .lineLimit(3, reservesSpace: true)
                } else {
                    Text(announcementContainsNoTextError)
                        .italic()
                        .foregroundStyle(.brightonSecondary)
                        .lineLimit(3, reservesSpace: true)
                }

            } else {
                Label("Unable to display content", systemImage: "xmark.circle")
                    .foregroundStyle(.red)
                    .frame(alignment: .leading)
                    .lineLimit(3, reservesSpace: true)
            }
            Divider()
            Text(verbatim: dateAndTime)
                .lineLimit(1)
                .font(.caption2)
                .foregroundStyle(.brightonSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .contraCard()
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center, spacing: 4) {
            //Image(systemName: "circle")
            Text(title)
                .lineLimit(1)
                .font(.headline)
            Spacer()

            if let markAsReadAction {
                Button(action: markAsReadAction) {
                    Label("Mark as Read", systemImage: "xmark")
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundStyle(.brightonSecondary)
                .imageScale(.large)
            }
        }
    }

    private var dateAndTime: String {
        if createdAt != editedAt {
            dateFormatter.string(from: createdAt) + " (Last edited: \(dateFormatter.string(from: editedAt)))"
        } else {
            dateFormatter.string(from: createdAt)
        }
    }

    private func createCardSummary(_ bbML: BbMLContent) -> String? {
        let textChunks = bbML.filter({
            if case .text(_) = $0 {
                return true
            } else {
                return false
            }
        })

        var attrString = AttributedString()
        for textChunk in textChunks {
            if !attrString.characters.isEmpty {
                attrString.append(AttributedString("\n"))
            }

            guard case .text(let chunkText) = textChunk else {
                return nil
            }

            attrString.append(chunkText)
        }

        return String(attrString.characters)
    }
}

extension ModuleAnnouncementCard {
    func onMarkAsRead(_ action: @escaping () -> Void) -> Self {
        var view = self
        view.markAsReadAction = action
        return view
    }
}

// MARK: Localisation
extension ModuleAnnouncementCard {
    private var announcementContainsNoTextError: LocalizedStringResource {
        .init(
            "course.announcements.no-preview-text",
            defaultValue: "This announcement contains no text.\nTap to open content.",
            table: "My Studies",
            comment: "Shown in announcement cards when the shown announcement does not contain any displayable text."
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ModuleAnnouncementCard(
        title: "Preview",
        bodyText: "<p>Preview body.<p/>",
        createdAt: .now,
        editedAt: .now
    )
}
