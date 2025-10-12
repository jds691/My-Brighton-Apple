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

public struct Term: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "Term")

    public let id: String
    public let externalId: String?
    public let dataSourceId: String?
    public let name: String
    public let description: String?
    public let availability: Term.Availability

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

    public struct Availability: Hashable, Sendable {
        public let isAvailable: Bool
        public let duration: Availability.Duration

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

        public enum Duration: Hashable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDays(_ days: Int)

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
        }
    }
}
