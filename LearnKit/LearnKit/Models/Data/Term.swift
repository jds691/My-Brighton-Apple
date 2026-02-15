//
//  Term.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/10/2025.
//

import Foundation
import os

/*
 (V3 API)
 Default fields when requesting terms are:
 - id
 - name
 - availability
 */

/// The term data model used by the service.
public struct Term: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "Term")

    /// The unique identifier of the term.
    public let id: String
    /// An optional secondary ID for the course.
    public let externalId: String?
    /// The ID of the data source this course belongs to.
    public let dataSourceId: String?
    /// The name of the term.
    public let name: String
    /// An optional description of the course.
    public let description: String?
    /// The availability settings of this term.
    public let availability: Term.Availability

    /// Initialises a term from a remote term from the Learn API.
    /// - Parameter termSchema: OpenAPI schema that the term is modeled after.
    init?(from termSchema: Components.Schemas.Term) {
        guard
            // Term Fields
            let id = termSchema.id,
            let name = termSchema.name,
            let availability = termSchema.availability,

            // Required Data Models
            let availabilityModel = Availability(from: availability)
        else {
            Self.logger.error("termSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
            dump(termSchema)
#endif

            return nil
        }

        self.id = id
        self.externalId = termSchema.externalId
        self.dataSourceId = termSchema.dataSourceId
        self.name = name
        self.description = termSchema.description
        self.availability = availabilityModel
    }

    /// Initialises a term from a cached instance.
    /// - Parameter cachedTerm: Cached instance of the term.
    init(from cachedTerm: CachedTerm) {
        self.id = cachedTerm.id
        self.externalId = cachedTerm.externalId
        self.dataSourceId = cachedTerm.dataSourceId
        self.name = cachedTerm.name
        self.description = cachedTerm.termDescription
        self.availability = Availability(from: cachedTerm.availability)
    }

    /// Initialises a new term from its raw fields.
    ///
    /// This is only intended for use in testing or previews.
    init(id: String, externalId: String?, dataSourceId: String?, name: String, description: String?, availability: Term.Availability) {
        self.id = id
        self.externalId = externalId
        self.dataSourceId = dataSourceId
        self.name = name
        self.description = description
        self.availability = availability
    }

    /// Indicates the availability status of a term.
    public struct Availability: Hashable, Sendable {
        /// Indicates if the term is currently available.
        public let isAvailable: Bool
        /// Indicates how long the term is available for.
        public let duration: Availability.Duration

        /// Initialises the availablility information from a value from the Learn API.
        /// - Parameter termAvailabilitySchema: OpenAPI schema that availability data is modeled after.
        init?(from termAvailabilitySchema: Components.Schemas.Term.AvailabilityPayload) {
            guard
                // Availability Fields
                let available = termAvailabilitySchema.available,
                let duration = termAvailabilitySchema.duration,

                // Required Data Models
                let durationModel = Availability.Duration(from: duration)
            else {
                Term.logger.error("termAvailabilitySchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                dump(termAvailabilitySchema)
#endif

                return nil
            }

            self.isAvailable = available == .yes
            self.duration = durationModel
        }

        /// Initialises availability information from a cached instance.
        /// - Parameter cachedTermAvailability: Cached instance of the availability information.
        init(from cachedTermAvailability: CachedTerm.Availability) {
            self.isAvailable = cachedTermAvailability.isAvailable
            self.duration = Availability.Duration(from: cachedTermAvailability.duration)
        }

        /// Initialises a new availability instance from its raw fields.
        ///
        /// This is only intended for use in testing or previews.
        init(isAvailable: Bool, duration: Availability.Duration) {
            self.isAvailable = isAvailable
            self.duration = duration
        }

        /// Represents the duration types for a terms availability.
        public enum Duration: Hashable, Sendable {
            /// The term is always available.
            case continuous
            /// The term is available between the specified start and end dates.
            /// - Parameter start: The start date at which the course is available.
            /// - Parameter end: The end date at which the course is no longer available.
            case dateRange(start: Date, end: Date)
            ///  The term is available for the specified number of days.
            ///  - Parameter days: The number of days for which the course is available.
            case numberOfDays(_ days: Int)

            /// Initialises the availablility duration from a value from the Learn API.
            /// - Parameter termAvailabilityDurationSchema: OpenAPI schema that duration is modeled after.
            init?(from termAvailabilityDurationSchema: Components.Schemas.Term.AvailabilityPayload.DurationPayload) {
                guard
                    let durationType = termAvailabilityDurationSchema._type
                else {
                    Term.logger.error("termAvailabilityDurationSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                    dump(termAvailabilityDurationSchema)
#endif

                    return nil
                }

                switch durationType {
                    case .continuous:
                        self = .continuous
                    case .dateRange:
                        guard
                            let startDate = termAvailabilityDurationSchema.start,
                            let endDate = termAvailabilityDurationSchema.end
                        else {
                            Term.logger.error("termAvailabilityDurationSchema is DateRange but is missing either `start` or `end` fields, unable to construt data model.")
#if DEBUG
                            dump(termAvailabilityDurationSchema)
#endif

                            return nil
                        }

                        self = .dateRange(start: startDate, end: endDate)
                    case .fixedNumDays:
                        guard
                            let days = termAvailabilityDurationSchema.daysOfUse
                        else {
                            Term.logger.error("termAvailabilityDurationSchema is NumberOfDays but is missing `daysOfUse` field, unable to construt data model.")
#if DEBUG
                            dump(termAvailabilityDurationSchema)
#endif

                            return nil
                        }

                        self = .numberOfDays(Int(days))
                }
            }

            /// Initialises availability duration from a cached instance.
            /// - Parameter cachedTermAvailabilityDuration: Cached instance of the availability duration.
            init(from cachedTermAvailabilityDuration: CachedTerm.Availability.Duration) {
                switch cachedTermAvailabilityDuration {
                    case .continuous:
                        self = .continuous
                    case .dateRange(let startDate, let endDate):
                        self = .dateRange(start: startDate, end: endDate)
                    case .numberOfDays(let days):
                        self = .numberOfDays(Int(days))
                }
            }
        }
    }
}
