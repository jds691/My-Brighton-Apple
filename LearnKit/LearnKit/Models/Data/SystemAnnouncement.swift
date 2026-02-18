//
//  SystemAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/10/2025.
//

import Foundation
import os

/// The system announcement data model used by the service.
public struct SystemAnnouncement: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "SystemAnnouncement")

    /// The unique identifier of the system announcement.
    public let id: String
    /// The title of the system announcement.
    public let title: String
    /// The text body of the system announcement.
    ///
    /// This is stored and formatted in BbML.
    public let body: String
    /// Indicates the availability of this system announcement.
    public let availability: Availability
    /// Indicates if the announcement should be shown on the login page.
    ///
    /// This doesn't apply to the My Brighton client so if this field is set to true it might be best to display it elsewhere.
    public let showAtLogin: Bool
    /// Indicates if the announcement should be shown alongside course announcements.
    public let showInCourses: Bool
    /// The ID of the user that created this announcement.
    public let creatorID: String
    /// The date on which this announcement was created.
    public let creationDate: Date
    /// The date on which this announcement was last edited.
    public let lastModified: Date

    // On My Brighton no system announcements are actually available, so it's not possible to see the default fields.
    // These requirements are modelled after course announcements

    /// Initialises a system announcement from a remote system announcement from the Learn API.
    /// - Parameter termSchema: OpenAPI schema that the system announcement is modeled after.
    init?(from systemAnnouncementSchema: Components.Schemas.SystemAnnouncement) {
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

    /// Initialises a system announcement from a cached instance.
    /// - Parameter cachedTerm: Cached instance of the system announcement.
    init(from cachedSystemAnnouncement: CachedSystemAnnouncement) {
        self.id = cachedSystemAnnouncement.id
        self.title = cachedSystemAnnouncement.title
        self.body = cachedSystemAnnouncement.body
        self.availability = SystemAnnouncement.Availability(from: cachedSystemAnnouncement.availability)
        self.showAtLogin = cachedSystemAnnouncement.showAtLogin
        self.showInCourses = cachedSystemAnnouncement.showInCourses
        self.creatorID = cachedSystemAnnouncement.creatorID
        self.creationDate = cachedSystemAnnouncement.creationDate
        self.lastModified = cachedSystemAnnouncement.lastModified
    }

    /// Represents the types of availability for a system announcement.
    public enum Availability: Hashable, Sendable {
        /// The system announcement is always available.
        case permenant
        /// The system announcement is only available for a fixed duration.
        case restricted(start: Date, end: Date)

        /// Initialises the availablility information from a value from the Learn API.
        /// - Parameter termAvailabilitySchema: OpenAPI schema that availability data is modeled after.
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

        /// Initialises availability information from a cached instance.
        /// - Parameter cachedTermAvailability: Cached instance of the availability information.
        init(from cachedSystemAnnouncementAvailability: CachedSystemAnnouncement.Availability) {
            switch cachedSystemAnnouncementAvailability {
                case .permenant:
                    self = .permenant
                case .restricted(let start, let end):
                    self = .restricted(start: start, end: end)
            }
        }
    }
}
