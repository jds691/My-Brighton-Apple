//
//  Course.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/08/2025.
//

import Foundation
import os

/*
 (V3 API)
 Default fields when requesting courses are:
 - id
 - courseId
 - name
 - modified
 - organization
 - ultraStatus
 - closedComplete
 - termId
 - availability (full)
 - enrollment
 - locale
    .force
 - externalAccessUrl
 - copyHistory
*/

public struct Course: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "Course")

    public let id: String
    public let uuid: UUID?
    public let externalId: String?
    public let dataSourceId: String?
    public let courseId: String
    public let name: String
    public let description: String?
    public let creationDate: Date?
    public let lastModified: Date
    public let isOrganisation: Bool
    public let ultraStatus: Course.UltraStatus
    public let allowGuests: Bool?
    public let allowObservers: Bool?
    public let isComplete: Bool
    public let termId: Term.ID
    public let availability: Course.Availability
    public let enrollmentType: Course.Enrollment
    public let localeSettings: Course.LocaleSettings
    public let hasChildren: Bool?
    public let parentId: Course.ID?
    public let externalAccessUrl: URL
    public let guestAccessUrl: URL?

    init?(from courseSchema: Components.Schemas.Course) {
        guard
            // Course Fields
            let id = courseSchema.id,
            let courseId = courseSchema.courseId,
            let name = courseSchema.name,
            let modified = courseSchema.modified,
            let organization = courseSchema.organization,
            let ultraStatus = courseSchema.ultraStatus,
            let closedComplete = courseSchema.closedComplete,
            let termId = courseSchema.termId, // ?
            let availability = courseSchema.availability,
            let enrollment = courseSchema.enrollment,
            let locale = courseSchema.locale,
            let externalAccessUrl = courseSchema.externalAccessUrl,

            // Required Data Models
            let availabilityModel = Availability(from: availability),
            let enrollmentModel = Enrollment(from: enrollment),
            let localeSettingsModel = LocaleSettings(from: locale)
        else {
            Self.logger.error("courseSchema is missing minimum required fields, unable to construt data model.")
            #if DEBUG
            dump(courseSchema)
            #endif

            return nil
        }

        self.id = id
        if let schemaUuid = courseSchema.uuid {
            self.uuid = UUID(uuidString: schemaUuid)
        } else {
            self.uuid = nil
        }
        self.externalId = courseSchema.externalId
        self.dataSourceId = courseSchema.dataSourceId
        self.courseId = courseId
        self.name = name
        self.description = courseSchema.description
        self.creationDate = courseSchema.created
        self.lastModified = modified
        self.isOrganisation = organization
        self.ultraStatus = UltraStatus(from: ultraStatus)
        self.allowGuests = courseSchema.allowGuests
        self.allowObservers = courseSchema.allowObservers
        self.isComplete = closedComplete
        self.termId = termId
        self.availability = availabilityModel
        self.enrollmentType = enrollmentModel
        self.localeSettings = localeSettingsModel
        self.hasChildren = courseSchema.hasChildren
        self.parentId = courseSchema.parentId
        if let externalAccessURL = URL(string: externalAccessUrl) {
            self.externalAccessUrl = externalAccessURL
        } else {
            Self.logger.error("courseSchema.externalAccessUrl is malformed, unable to construct data model.")
            #if DEBUG
            dump(externalAccessUrl)
            #endif
            return nil
        }

        self.guestAccessUrl = URL(string: courseSchema.guestAccessUrl ?? "")
    }

    public enum UltraStatus: Hashable, Sendable {
        case unknown
        case classic
        case ultra
        case ultraPreview

        init(from ultraStatusSchema: Components.Schemas.Course.UltraStatusPayload) {
            switch ultraStatusSchema {
                case .undecided:
                    self = .unknown
                case .classic:
                    self = .classic
                case .ultra:
                    self = .ultra
                case .ultrapreview:
                    self = .ultraPreview
            }
        }
    }

    public enum Enrollment: Hashable, Sendable {
        case instructorLed
        case selfEnrollment(enrollmentStart: Date, enrollmentEnd: Date, accessCode: String?)
        case emailEnrollment

        init?(from enrollmentSchema: Components.Schemas.Course.EnrollmentPayload) {
            guard
                let enrollmentType = enrollmentSchema._type
            else {
                Course.logger.error("enrollmentSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                dump(enrollmentSchema)
#endif

                return nil
            }

            switch enrollmentType {
                case .selfEnrollment:
                    guard
                        let startDate = enrollmentSchema.start,
                        let endDate = enrollmentSchema.end
                    else {
                        Course.logger.error("enrollmentSchema is SelfEnrollment but is missing either `start` or `end` fields, unable to construt data model.")
#if DEBUG
                        dump(enrollmentSchema)
#endif

                        return nil
                    }

                    self = .selfEnrollment(enrollmentStart: startDate, enrollmentEnd: endDate, accessCode: enrollmentSchema.accessCode)
                case .emailEnrollment:
                    self = .emailEnrollment
                case .instructorLed:
                    self = .instructorLed
            }
        }
    }

    public struct Availability: Hashable, Sendable {
        public let status: Self.Status
        public let duration: Self.Duration

        init?(from availabilitySchema: Components.Schemas.Course.AvailabilityPayload) {
            guard
                // Availability Fields
                let status = availabilitySchema.available,
                let duration = availabilitySchema.duration,

                // Required Data Models
                let statusModel = Status(rawValue: status.rawValue),
                let durationModel = Duration(from: duration)
            else {
                Course.logger.error("availabilitySchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                dump(availabilitySchema)
#endif

                return nil
            }

            self.status = statusModel
            self.duration = durationModel
        }

        public enum Status: String, RawRepresentable, Hashable, Sendable {
            case yes = "Yes"
            case no = "No"
            case disabled = "Disabled"
            case inheritFromTerm = "Term"
        }

        public enum Duration: Hashable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDays(_ days: Int)
            case inheritFromTerm

            init?(from durationSchema: Components.Schemas.Course.AvailabilityPayload.DurationPayload) {
                guard
                    let durationType = durationSchema._type
                else {
                    Course.logger.error("durationSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                    dump(durationSchema)
#endif

                    return nil
                }

                switch durationType {
                    case .continuous:
                        self = .continuous
                    case .dateRange:
                        guard
                            let startDate = durationSchema.start,
                            let endDate = durationSchema.end
                        else {
                            Course.logger.error("enrollmentSchema is DateRange but is missing either `start` or `end` fields, unable to construt data model.")
#if DEBUG
                            dump(durationSchema)
#endif

                            return nil
                        }

                        self = .dateRange(start: startDate, end: endDate)
                    case .fixedNumDays:
                        guard
                            let days = durationSchema.daysOfUse
                        else {
                            Course.logger.error("enrollmentSchema is NumberOfDays but is missing `daysOfUse` field, unable to construt data model.")
#if DEBUG
                            dump(durationSchema)
#endif

                            return nil
                        }

                        self = .numberOfDays(Int(days))
                    case .useTerm:
                        self = .inheritFromTerm
                }
            }
        }
    }

    public struct LocaleSettings: Hashable, Sendable {
        public let identifier: String?
        public let forceLocale: Bool

        init?(from localeSchema: Components.Schemas.Course.LocalePayload) {
            guard
                let forceLocale = localeSchema.force
            else {
                Course.logger.error("localeSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                dump(localeSchema)
#endif

                return nil
            }

            self.identifier = localeSchema.id
            self.forceLocale = forceLocale
        }
    }
}
