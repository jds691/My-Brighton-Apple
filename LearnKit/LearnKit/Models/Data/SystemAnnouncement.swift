//
//  SystemAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/10/2025.
//

import Foundation
import os

// TODO: DocC comments
public struct SystemAnnouncement: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "SystemAnnouncement")

    public let id: String
    public let title: String
    public let body: String
    public let availability: Availability
    public let showAtLogin: Bool
    public let showInCourses: Bool
    public let creatorID: String
    public let creationDate: Date
    public let lastModified: Date

    // On My Brighton no system announcements are actually available, so it's not possible to see the default fields.
    // These requirements are modelled after course announcements
    init?(systemAnnouncementSchema: Components.Schemas.SystemAnnouncement) {
        guard
            // System Announcement Fields
            let id = systemAnnouncementSchema.id,
            let title = systemAnnouncementSchema.title,
            let body = systemAnnouncementSchema.body,
            let availability = systemAnnouncementSchema.availability,
            let creatorId = systemAnnouncementSchema.creatorUserId,
            let creationDate = systemAnnouncementSchema.created,
            let lastModified = systemAnnouncementSchema.modified,

            // Required Data Models
            let availabilityModel = Availability(from: availability)
        else {
            Self.logger.error("systemAnnouncementSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
            dump(systemAnnouncementSchema)
#endif

            return nil
        }
        
        self.id = id
        self.title = title
        self.body = body
        self.availability = availabilityModel
        self.showAtLogin = systemAnnouncementSchema.showAtLogin ?? false
        self.showInCourses = systemAnnouncementSchema.showInCourses ?? false
        self.creatorID = creatorId
        self.creationDate = creationDate
        self.lastModified = lastModified
    }

    public enum Availability: Hashable, Sendable {
        case permenant
        case restricted(start: Date, end: Date)

        init?(from systemAnnouncementAvailabilitySchema: Components.Schemas.SystemAnnouncement.AvailabilityPayload) {
            guard
                let duration = systemAnnouncementAvailabilitySchema.duration,
                let durationType = duration._type
            else {
                SystemAnnouncement.logger.error("systemAnnouncementAvailabilitySchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                dump(systemAnnouncementAvailabilitySchema)
#endif

                return nil
            }

            switch durationType {
                case .permanent:
                    self = .permenant
                case .restricted:
                    guard
                        let startDate = duration.start,
                        let endDate = duration.end
                    else {
                        SystemAnnouncement.logger.error("systemAnnouncementAvailabilitySchema is Restricted but is missing either `start` or `end` fields, unable to construt data model.")
#if DEBUG
                        dump(systemAnnouncementAvailabilitySchema)
#endif

                        return nil
                    }

                    self = .restricted(start: startDate, end: endDate)
            }
        }
    }
}
