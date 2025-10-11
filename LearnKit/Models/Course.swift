//
//  Course.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/08/2025.
//

import Foundation

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

    init(from courseSchema: Components.Schemas.Course) {
        self.id = courseSchema.id!
        if let schemaUuid = courseSchema.uuid {
            self.uuid = UUID(uuidString: schemaUuid)
        } else {
            self.uuid = nil
        }
        self.externalId = courseSchema.externalId
        self.dataSourceId = courseSchema.dataSourceId
        self.courseId = courseSchema.courseId!
        self.name = courseSchema.name!
        self.description = courseSchema.description
        self.creationDate = courseSchema.created
        self.lastModified = courseSchema.modified!
        self.isOrganisation = courseSchema.organization!
        self.ultraStatus = UltraStatus(from: courseSchema.ultraStatus!)
        self.allowGuests = courseSchema.allowGuests
        self.allowObservers = courseSchema.allowObservers
        self.isComplete = courseSchema.closedComplete!
        self.termId = courseSchema.termId! // ?
        self.availability = Availability(from: courseSchema.availability!)
        self.enrollmentType = Enrollment(from: courseSchema.enrollment!)
        self.localeSettings = LocaleSettings(from: courseSchema.locale!)
        self.hasChildren = courseSchema.hasChildren
        self.parentId = courseSchema.parentId
        self.externalAccessUrl = URL(string: courseSchema.externalAccessUrl!)!
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

        init(from enrollmentSchema: Components.Schemas.Course.EnrollmentPayload) {
            switch enrollmentSchema._type {
                case .selfEnrollment:
                    self = .selfEnrollment(enrollmentStart: enrollmentSchema.start!, enrollmentEnd: enrollmentSchema.end!, accessCode: enrollmentSchema.accessCode!)
                case .emailEnrollment:
                    self = .emailEnrollment
                case .instructorLed:
                    self = .instructorLed
                default:
                    fatalError()
            }
        }
    }

    public struct Availability: Hashable, Sendable {
        public let status: Self.Status
        public let duration: Self.Duration

        init(from availabilitySchema: Components.Schemas.Course.AvailabilityPayload) {
            self.status = Status(rawValue: availabilitySchema.available!.rawValue)!
            self.duration = Duration(from: availabilitySchema.duration!)
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

            init(from durationSchema: Components.Schemas.Course.AvailabilityPayload.DurationPayload) {
                switch durationSchema._type {
                    case .continuous:
                        self = .continuous
                    case .dateRange:
                        self = .dateRange(start: durationSchema.start!, end: durationSchema.end!)
                    case .fixedNumDays:
                        self = .numberOfDays(Int(durationSchema.daysOfUse!))
                    case .useTerm:
                        self = .inheritFromTerm
                    default:
                        fatalError()
                }
            }
        }
    }

    public struct LocaleSettings: Hashable, Sendable {
        public let identifier: String?
        public let forceLocale: Bool

        init(from localeSchema: Components.Schemas.Course.LocalePayload) {
            self.identifier = localeSchema.id
            self.forceLocale = localeSchema.force!
        }
    }
}
