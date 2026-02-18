//
//  CourseAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 16/02/2026.
//

import Foundation
import os

public struct CourseAnnouncement: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "CourseAnnouncement")

    public let id: String
    public let title: String
    public let body: String
    public let isDraft: Bool
    public let availability: Availability
    public let creatorId: String
    public let creationDate: Date
    public let lastModifiedDate: Date
    public let reachedUsersCount: Int?
    public let positionIndex: Int
    public let readCount: Int?

    init?(from courseAnnouncementSchema: Components.Schemas.CourseAnnouncement) {
        guard
            // Course Announcement Fields
            let id = courseAnnouncementSchema.id,
            let title = courseAnnouncementSchema.title,
            let body = courseAnnouncementSchema.body,
            let isDraft = courseAnnouncementSchema.draft,
            let availability = courseAnnouncementSchema.availability,
            let creatorId = courseAnnouncementSchema.creatorUserId,
            let creationDate = courseAnnouncementSchema.created,
            let lastModified = courseAnnouncementSchema.modified,
            let positionIndex = courseAnnouncementSchema.position,

                // Required Data Models
            let availabilityModel = Availability(from: availability)
        else {
            Self.logger.error("courseAnnouncementSchema is missing minimum required fields, unable to construct data model.")
#if DEBUG
            dump(courseAnnouncementSchema)
#endif

            return nil
        }

        self.id = id
        self.title = title
        self.body = body
        self.isDraft = isDraft
        self.availability = availabilityModel
        self.creatorId = creatorId
        self.creationDate = creationDate
        self.lastModifiedDate = lastModified
        self.positionIndex = Int(positionIndex)

        if let participants = courseAnnouncementSchema.participants {
            self.reachedUsersCount = Int(participants)
        } else {
            self.reachedUsersCount = nil
        }

        if let readCount = courseAnnouncementSchema.readCount {
            self.readCount = Int(readCount)
        } else {
            self.readCount = nil
        }
    }

    public enum Availability: Hashable, Sendable {
        case permanent
        case restricted(start: Date, end: Date)

        init?(from courseAnnouncementAvailabilitySchema: Components.Schemas.CourseAnnouncement.AvailabilityPayload) {
            guard
                let duration = courseAnnouncementAvailabilitySchema.duration,
                let durationType = duration._type
            else {
                CourseAnnouncement.logger.error("courseAnnouncementAvailabilitySchema is missing minimum required fields, unable to construct data model.")
#if DEBUG
                dump(courseAnnouncementAvailabilitySchema)
#endif

                return nil
            }

            switch durationType {
                case .permanent:
                    self = .permanent
                case .restricted:
                    guard
                        let startDate = duration.start,
                        let endDate = duration.end
                    else {
                        CourseAnnouncement.logger.error("courseAnnouncementAvailabilitySchema is Restricted but is missing either `start` or `end` fields, unable to construt data model.")
#if DEBUG
                        dump(courseAnnouncementAvailabilitySchema)
#endif

                        return nil
                    }

                    self = .restricted(start: startDate, end: endDate)
            }
        }
    }
}
