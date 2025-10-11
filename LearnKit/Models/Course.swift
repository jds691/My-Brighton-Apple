//
//  Course.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/08/2025.
//

import Foundation

public struct Course: Hashable, Identifiable, Sendable {
    public let id: String
    public let uuid: UUID
    public let externalId: String
    public let dataSourceId: String
    public let courseId: String
    public let name: String
    public let description: String
    public let creationDate: Date
    public let lastModified: Date
    public let isOrganisation: Bool
    public let ultraStatus: Course.UltraStatus
    public let allowGuests: Bool
    public let allowObservers: Bool
    public let isComplete: Bool
    public let termId: Term.ID
    public let availability: Course.Availability
    public let enrollmentType: Course.Enrollment
    public let localeSettings: Course.LocaleSettings
    public let hasChildren: Bool
    public let parentId: Course.ID?
    public let externalAccessUrl: URL
    public let guestAccessUrl: URL?

    public enum UltraStatus: Hashable, Sendable {
        case unknown
        case classic
        case ultra
        case ultraPreview
    }

    public enum Enrollment: Hashable, Sendable {
        case instructorLed
        case selfEnrollment(enrollmentStart: Date, enrollmentEnd: Date, accessCode: String)
        case emailEnrollment
    }

    public struct Availability: Hashable, Sendable {
        public let status: Self.Status
        public let duration: Self.Duration

        public enum Status: Hashable, Sendable {
            case yes
            case no
            case disabled
            case inheritFromTerm
        }

        public enum Duration: Hashable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDats(_ days: Int)
            case inheritFromTerm
        }
    }

    public struct LocaleSettings: Hashable, Sendable {
        public let identifier: String
        public let forceLocale: Bool
    }
}
