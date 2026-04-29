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

/// The course data model used by the service.
public struct Course: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "Course")

    /// The unique identifier of the course.
    public let id: String
    /// An optional secondary ID for the course.
    public let uuid: UUID?
    /// An optional secondary ID for the course.
    public let externalId: String?
    /// The ID of the data source this course belongs to.
    public let dataSourceId: String?
    /// The user-defined ID of the course, suitable to be displayed to users.
    public let courseId: String
    /// The name of the course.
    public let name: String
    /// An optional description of the course.
    public let description: String?
    /// The creation date of the course, if it is available.
    public let creationDate: Date?
    /// The date that the data for this course was last modified.
    public let lastModified: Date
    /// Indicates if this course is an organisation.
    public let isOrganisation: Bool
    /// The status of this course, indicating if it is an Ultra course or not.
    public let ultraStatus: Course.UltraStatus
    /// Indicates if this course allows guests to view or join it.
    public let allowGuests: Bool?
    public let allowObservers: Bool?
    /// Indicates if this course is finished.
    ///
    /// Ultra courses will no longer be able to received updates if it is complete, classic courses can still be updated but no notifications are generated.
    public let isComplete: Bool
    /// The ID of the term this course belongs to.
    public let termId: Term.ID
    /// The availability settings of this course.
    public let availability: Course.Availability
    /// The enrollment style for this course.
    public let enrollmentType: Course.Enrollment
    /// The locale settings for this course.
    public let localeSettings: Course.LocaleSettings
    /// Indicates if this course has children.
    public let hasChildren: Bool?
    /// The parent ID of this course, if it is a child course.
    public let parentId: Course.ID?
    /// The URL that can be used externally to access this course online.
    public let externalAccessUrl: URL
    /// The URL that guests can use to access this course online.
    public let guestAccessUrl: URL?
    
    /// Initialises a course from a remote course from the Learn API.
    /// - Parameter courseSchema: OpenAPI schema that the course is modeled after.
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
    
    /// Initialises a course from a cached instance.
    /// - Parameter cachedCourse: Cached instance of the course.
    init?(from cachedCourse: CachedCourse) {
        guard let termId = cachedCourse.term?.id else {
            Self.logger.error("cachedCourse is missing required relationship information for `term`. Unable to construct data model.")
            #if DEBUG
            dump(cachedCourse)
            #endif
            return nil
        }

        self.id = cachedCourse.id
        self.uuid = cachedCourse.uuid
        self.externalId = cachedCourse.externalId
        self.dataSourceId = cachedCourse.dataSourceId
        self.courseId = cachedCourse.courseId
        self.name = cachedCourse.name
        self.description = cachedCourse.courseDescription
        self.creationDate = cachedCourse.creationDate
        self.lastModified = cachedCourse.lastModified
        self.isOrganisation = cachedCourse.isOrganisation
        self.ultraStatus = UltraStatus(from: cachedCourse.ultraStatus)
        self.allowGuests = cachedCourse.allowGuests
        self.allowObservers = cachedCourse.allowObservers
        self.isComplete = cachedCourse.isComplete
        self.termId = termId
        self.availability = Availability(from: cachedCourse.availability)
        self.enrollmentType = Enrollment(from: cachedCourse.enrollmentType)
        self.localeSettings = LocaleSettings(from: cachedCourse.localeSettings)
        self.hasChildren = !cachedCourse.childCourses.isEmpty
        self.parentId = cachedCourse.parent?.id
        self.externalAccessUrl = cachedCourse.externalAccessUrl
        self.guestAccessUrl = cachedCourse.guestAccessUrl
    }
    
    /// Initialises a new course from its raw fields.
    ///
    /// This is only intended for use in testing or previews.
    init(id: String, uuid: UUID?, externalId: String?, dataSourceId: String?, courseId: String, name: String, description: String?, creationDate: Date?, lastModified: Date, isOrganisation: Bool, ultraStatus: Course.UltraStatus, allowGuests: Bool?, allowObservers: Bool?, isComplete: Bool, termId: Term.ID, availability: Course.Availability, enrollmentType: Course.Enrollment, localeSettings: Course.LocaleSettings, hasChildren: Bool?, parentId: Course.ID?, externalAccessUrl: URL, guestAccessUrl: URL?) {
        self.id = id
        self.uuid = uuid
        self.externalId = externalId
        self.dataSourceId = dataSourceId
        self.courseId = courseId
        self.name = name
        self.description = description
        self.creationDate = creationDate
        self.lastModified = lastModified
        self.isOrganisation = isOrganisation
        self.ultraStatus = ultraStatus
        self.allowGuests = allowGuests
        self.allowObservers = allowObservers
        self.isComplete = isComplete
        self.termId = termId
        self.availability = availability
        self.enrollmentType = enrollmentType
        self.localeSettings = localeSettings
        self.hasChildren = hasChildren
        self.parentId = parentId
        self.externalAccessUrl = externalAccessUrl
        self.guestAccessUrl = guestAccessUrl
    }
    
    /// Indicates if a course is an Ultra course or not.
    public enum UltraStatus: Hashable, Sendable {
        /// It is unknown if the course is an Ultra course.
        case unknown
        /// The course is a Classic course.
        case classic
        /// The course is an Ultra course.
        case ultra
        /// The course is a classic course but it is being previewed in the Ultra UI.
        case ultraPreview
        
        /// Initialises an Ultra status instances from a remote Ultra status value from the Learn API.
        /// - Parameter ultraStatusSchema: OpenAPI schema that status is modeled after.
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

        /// Initialises an Ultra status value from a cached instance.
        /// - Parameter cachedUltraStatus: Cached instance of the status.
        init(from cachedUltraStatus: CachedCourse.UltraStatus) {
            switch cachedUltraStatus {
                case .unknown:
                    self = .unknown
                case .classic:
                    self = .classic
                case .ultra:
                    self = .ultra
                case .ultraPreview:
                    self = .ultraPreview
            }
        }
    }
    
    /// Indicates the enrollment type for the course.
    public enum Enrollment: Hashable, Sendable {
        /// The course is instructor led.
        ///
        /// Students must be added to the course by an instructor.
        case instructorLed
        /// Students can enroll themself into the course.
        /// - Parameter enrollmentStart: The date from which students can start enrolling themselves onto this course.
        /// - Parameter enrollmentEnd: The date at which students can no longer enroll themselves onto this course.
        /// - Parameter accessCode: The accesss code required to access the course.
        case selfEnrollment(enrollmentStart: Date, enrollmentEnd: Date, accessCode: String?)
        /// Students can be enrolled via email invite.
        case emailEnrollment

        /// Initialises an enrollment type from a remote value from the Learn API.
        /// - Parameter enrollmentSchema: OpenAPI schema that enrollment types are modeled after.
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

        /// Initialises an enrollment type from a cached instance.
        /// - Parameter cachedCourseEnrollment: Cached instance of the enrollment type.
        init(from cachedCourseEnrollment: CachedCourse.Enrollment) {
            switch cachedCourseEnrollment {
                case .instructorLed:
                    self = .instructorLed
                case .selfEnrollment(let enrollmentStart, let enrollmentEnd, let accessCode):
                    self = .selfEnrollment(enrollmentStart: enrollmentStart, enrollmentEnd: enrollmentEnd, accessCode: accessCode)
                case .emailEnrollment:
                    self = .emailEnrollment
            }
        }
    }
    
    /// Indicates the availability status of a course.
    public struct Availability: Hashable, Sendable {
        /// The status for if the course is available or not.
        public let status: Self.Status
        /// Indicates how long the course is available for.
        public let duration: Self.Duration

        /// Initialises the availablility information from a value from the Learn API.
        /// - Parameter availabilitySchema: OpenAPI schema that availability data is modeled after.
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

        /// Initialises availability information from a cached instance.
        /// - Parameter cachedCourseEnrollment: Cached instance of the availability information.
        init(from cachedCourseAvailability: CachedCourse.Availability) {
            self.status = Status(from: cachedCourseAvailability.status)
            self.duration = Duration(from: cachedCourseAvailability.duration)
        }

        /// Initialises a new availability instance from its raw fields.
        ///
        /// This is only intended for use in testing or previews.
        init(status: Availability.Status, duration: Availability.Duration) {
            self.status = status
            self.duration = duration
        }
        
        /// Represents the status types for course availability.
        public enum Status: String, RawRepresentable, Hashable, Sendable {
            /// The course is available.
            case yes = "Yes"
            /// The course is not available.
            case no = "No"
            case disabled = "Disabled"
            /// Course availability is determined by its associated term.
            case inheritFromTerm = "Term"

            /// Initialises availability status from a cached instance.
            /// - Parameter cachedCourseEnrollment: Cached instance of the availability status.
            init(from cachedCourseAvailabilityStatus: CachedCourse.Availability.Status) {
                switch cachedCourseAvailabilityStatus {
                    case .yes:
                        self = .yes
                    case .no:
                        self = .no
                    case .disabled:
                        self = .disabled
                    case .inheritFromTerm:
                        self = .inheritFromTerm
                }
            }
        }
        
        /// Represents the duration types for a courses availability.
        public enum Duration: Hashable, Sendable {
            /// The course is always available.
            case continuous
            /// The course is available between the specified start and end dates.
            /// - Parameter start: The start date at which the course is available.
            /// - Parameter end: The end date at which the course is no longer available.
            case dateRange(start: Date, end: Date)
            ///  The course is available for the specified number of days.
            ///  - Parameter days: The number of days for which the course is available.
            case numberOfDays(_ days: Int)
            /// The duration for which the course available is determined by its associated term.
            case inheritFromTerm

            /// Initialises the availablility duration from a value from the Learn API.
            /// - Parameter durationSchema: OpenAPI schema that duration is modeled after.
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
                    case .term:
                        self = .inheritFromTerm
                }
            }

            /// Initialises availability duration from a cached instance.
            /// - Parameter cachedCourseEnrollment: Cached instance of the availability duration.
            init(from cachedCourseAvailabilityDuration: CachedCourse.Availability.Duration) {
                switch cachedCourseAvailabilityDuration {
                    case .continuous:
                        self = .continuous
                    case .dateRange(let start, let end):
                        self = .dateRange(start: start, end: end)
                    case .numberOfDays(let days):
                        self = .numberOfDays(days)
                    case .inheritFromTerm:
                        self = .inheritFromTerm
                }
            }
        }
    }

    /// Indicates the locale settings of a course.
    public struct LocaleSettings: Hashable, Sendable {
        /// The identifier of the locale that the course prefers.
        public let identifier: String?
        /// Indicates if the course must be viewed in the specified locale.
        public let forceLocale: Bool

        /// Initialises the locale settings from a value from the Learn API.
        /// - Parameter localeSchema: OpenAPI schema that locale settings are modeled after.
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

        /// Initialises locale settings from a cached instance.
        /// - Parameter cachedCourseLocaleSettings: Cached instance of the locale settings.
        init(from cachedCourseLocaleSettings: CachedCourse.LocaleSettings) {
            self.identifier = cachedCourseLocaleSettings.identifier
            self.forceLocale = cachedCourseLocaleSettings.isForced
        }

        /// Initialises a new set of locale settings from its raw fields.
        ///
        /// This is only intended for use in testing or previews.
        init(identifier: String?, forceLocale: Bool) {
            self.identifier = identifier
            self.forceLocale = forceLocale
        }
    }
}
