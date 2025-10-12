//
//  Term.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/10/2025.
//

import Foundation

/*
 (V3 API)
 Default fields when requesting terms are:
 - id
 - name
 - availability
 */

public struct Term: Hashable, Identifiable, Sendable {
    public let id: String
    public let externalId: String?
    public let dataSourceId: String?
    public let name: String
    public let description: String?
    public let availability: Term.Availability

    init(from termSchema: Components.Schemas.Term) {
        self.id = termSchema.id!
        self.externalId = termSchema.externalId
        self.dataSourceId = termSchema.dataSourceId
        self.name = termSchema.name!
        self.description = termSchema.description
        self.availability = Availability(from: termSchema.availability!)
    }

    public struct Availability: Hashable, Sendable {
        public let isAvailable: Bool
        public let duration: Availability.Duration

        init(from termAvailabilitySchema: Components.Schemas.Term.AvailabilityPayload) {
            self.isAvailable = termAvailabilitySchema.available! == .yes
            self.duration = Availability.Duration(from: termAvailabilitySchema.duration!)
        }

        public enum Duration: Hashable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDays(_ days: Int)

            init(from termAvailabilityDurationSchema: Components.Schemas.Term.AvailabilityPayload.DurationPayload) {
                switch termAvailabilityDurationSchema._type! {
                    case .continuous:
                        self = .continuous
                    case .dateRange:
                        self = .dateRange(start: termAvailabilityDurationSchema.start!, end: termAvailabilityDurationSchema.end!)
                    case .fixedNumDays:
                        self = .numberOfDays(Int(termAvailabilityDurationSchema.daysOfUse!))
                }
            }
        }
    }
}
