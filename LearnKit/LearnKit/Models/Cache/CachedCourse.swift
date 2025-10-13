//
//  CachedCourse.swift
//  My Brighton
//
//  Created by Neo Salmon on 12/10/2025.
//

import Foundation
import SwiftData

@Model
class CachedCourse {
    var id: Course.ID
    var uuid: UUID?
    var externalId: String?
    var dataSourceId: String?
    var courseId: String
    var name: String
    var courseDescription: String?
    var creationDate: Date?
    var lastModified: Date
    var isOrganisation: Bool
    var ultraStatus: CachedCourse.UltraStatus
    var allowGuests: Bool?
    var allowObservers: Bool?
    var isComplete: Bool
    var enrollmentType: CachedCourse.Enrollment
    var externalAccessUrl: URL
    var guestAccessUrl: URL?
    var localeSettings: CachedCourse.LocaleSettings
    var availability: CachedCourse.Availability

    // Relational Fields
    var term: CachedTerm? = nil
    var parent: CachedCourse? = nil
    @Relationship(inverse: \CachedCourse.parent)
    var children: [CachedCourse] = []

    init(from courseModel: Course) {
        self.id = courseModel.id
        self.uuid = courseModel.uuid
        self.externalId = courseModel.externalId
        self.dataSourceId = courseModel.dataSourceId
        self.courseId = courseModel.courseId
        self.name = courseModel.name
        self.courseDescription = courseModel.description
        self.creationDate = courseModel.creationDate
        self.lastModified = courseModel.lastModified
        self.isOrganisation = courseModel.isOrganisation
        self.ultraStatus = UltraStatus(from: courseModel.ultraStatus)
        self.allowGuests = courseModel.allowGuests
        self.allowObservers = courseModel.allowObservers
        self.isComplete = courseModel.isComplete
        self.enrollmentType = Enrollment(from: courseModel.enrollmentType)
        self.externalAccessUrl = courseModel.externalAccessUrl
        self.guestAccessUrl = courseModel.guestAccessUrl

        self.localeSettings = LocaleSettings(from: courseModel.localeSettings)
        self.availability = Availability(from: courseModel.availability)
    }

    func copyValues(from courseModel: Course) {
        self.id = courseModel.id
        self.uuid = courseModel.uuid
        self.externalId = courseModel.externalId
        self.dataSourceId = courseModel.dataSourceId
        self.courseId = courseModel.courseId
        self.name = courseModel.name
        self.courseDescription = courseModel.description
        self.creationDate = courseModel.creationDate
        self.lastModified = courseModel.lastModified
        self.isOrganisation = courseModel.isOrganisation
        self.ultraStatus = UltraStatus(from: courseModel.ultraStatus)
        self.allowGuests = courseModel.allowGuests
        self.allowObservers = courseModel.allowObservers
        self.isComplete = courseModel.isComplete
        self.enrollmentType = Enrollment(from: courseModel.enrollmentType)
        self.externalAccessUrl = courseModel.externalAccessUrl
        self.guestAccessUrl = courseModel.guestAccessUrl

        self.localeSettings = LocaleSettings(from: courseModel.localeSettings)
        self.availability = Availability(from: courseModel.availability)
    }

    enum UltraStatus: String, Hashable, Codable, Sendable {
        case unknown = "Undecided"
        case classic = "Classic"
        case ultra = "Ultra"
        case ultraPreview = "Ultrapreview"

        init(from courseUltraStatusModel: Course.UltraStatus) {
            switch courseUltraStatusModel {
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

    enum Enrollment: Hashable, Codable, Sendable {
        case instructorLed
        case selfEnrollment(
            enrollmentStart: Date,
            enrollmentEnd: Date,
            accessCode: String?
        )
        case emailEnrollment

        init(from courseEnrollmentModel: Course.Enrollment) {
            switch courseEnrollmentModel {
                case .instructorLed:
                    self = .instructorLed
                case .selfEnrollment(
                    let enrollmentStart,
                    let enrollmentEnd,
                    let accessCode
                ):
                    self = .selfEnrollment(
                        enrollmentStart: enrollmentStart,
                        enrollmentEnd: enrollmentEnd,
                        accessCode: accessCode
                    )
                case .emailEnrollment:
                    self = .emailEnrollment
            }
        }
    }

    struct Availability: Hashable, Codable, Sendable {
        public let status: Availability.Status
        public let duration: Availability.Duration

        init(from courseAvailabilityModel: Course.Availability) {
            self.status = Status(from: courseAvailabilityModel.status)
            self.duration = Duration(from: courseAvailabilityModel.duration)
        }

        enum Status: String, Hashable, Codable, Sendable {
            case yes = "Yes"
            case no = "No"
            case disabled = "Disabled"
            case inheritFromTerm = "Term"

            init(
                from courseAvailabilityStatusModel: Course.Availability.Status
            ) {
                switch courseAvailabilityStatusModel {
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

        enum Duration: Hashable, Codable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDays(_ days: Int)
            case inheritFromTerm

            init(
                from courseAvailabilityDurationModel: Course.Availability.Duration
            ) {
                switch courseAvailabilityDurationModel {
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

    struct LocaleSettings: Hashable, Codable, Sendable {
        let identifier: String?
        let isForced: Bool

        init(from courseLocaleSettingsModel: Course.LocaleSettings) {
            self.identifier = courseLocaleSettingsModel.identifier
            self.isForced = courseLocaleSettingsModel.forceLocale
        }
    }
}
