//
//  CourseAnnouncementEntity.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/02/2026.
//

import AppIntents
import SwiftBbML

public struct CourseAnnouncementEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Course Announcement")
    }

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(title)")
    }

    public static let defaultQuery = CourseAnnouncementEntityQuery()

    public let id: String
    @Property(title: "ID")
    public var announcementId: CourseAnnouncement.ID
    @Property(title: "Title")
    public var title: String
    @Property(title: "Body")
    public var body: String
    @Property(title: "Availability Type")
    public var availabilityType: Availability
    @Property(title: "Availability Start")
    public var availabilityStart: Date?
    @Property(title: "Availability End")
    public var availabilityEnd: Date?
    @Property(title: "Creator ID")
    public var creatorId: String
    @Property(title: "Creation Date")
    public var creationDate: Date
    @Property(title: "Last Edited Date")
    public var lastModifiedDate: Date

    init(from courseAnnouncementModel: CourseAnnouncement, course courseId: Course.ID) {
        self.id = "\(courseId)/\(courseAnnouncementModel.id)"
        self.announcementId = courseAnnouncementModel.id
        self.title = courseAnnouncementModel.title
        self.body = Self.returnBbMLText(courseAnnouncementModel.body) ?? ""
        switch courseAnnouncementModel.availability {
            case .permanent:
                self.availabilityType = .permanent
                self.availabilityStart = nil
                self.availabilityEnd = nil
            case .restricted(let start, let end):
                self.availabilityType = .restricted
                self.availabilityStart = start
                self.availabilityEnd = end
        }
        self.creatorId = courseAnnouncementModel.creatorId
        self.creationDate = courseAnnouncementModel.creationDate
        self.lastModifiedDate = courseAnnouncementModel.lastModifiedDate
    }

    private static func returnBbMLText(_ bbMLString: String) -> String? {
        guard let content = try? BbMLParser().parse(bbMLString) else {
            return nil
        }

        let textChunks = content.filter({
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

    public enum Availability: String, AppEnum {
        case permanent = "Permenant"
        case restricted = "Restricted"

        public static var typeDisplayRepresentation: TypeDisplayRepresentation {
            .init(name: "Availability")
        }

        public static let caseDisplayRepresentations: [CourseAnnouncementEntity.Availability : DisplayRepresentation] = [
            .permanent : DisplayRepresentation(title: "Permenant"),
            .restricted: DisplayRepresentation(title: "Resricted")
        ]
    }
}
