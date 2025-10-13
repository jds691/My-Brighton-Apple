//
//  CachedTerm.swift
//  My Brighton
//
//  Created by Neo Salmon on 12/10/2025.
//

import Foundation
import SwiftData

@Model
class CachedTerm {
    // Term data model fields
    var id: Term.ID
    var externalId: String?
    var dataSourceId: String?
    var name: String
    var termDescription: String?
    var availability: CachedTerm.Availability

    // Relational fields
    @Relationship(inverse: \CachedCourse.term)
    var courses: [CachedCourse] = []

    init(from termModel: Term) {
        self.id = termModel.id
        self.externalId = termModel.externalId
        self.dataSourceId = termModel.dataSourceId
        self.name = termModel.name
        self.termDescription = termModel.description

        self.availability = Availability(from: termModel.availability)
    }

    /// Copys the values from a term data model into the cached instance.
    /// - Parameter termModel: Data model to copy.
    func copyValues(from termModel: Term) {
        self.id = termModel.id
        self.externalId = termModel.externalId
        self.dataSourceId = termModel.dataSourceId
        self.name = termModel.name
        self.termDescription = termModel.description

        self.availability = Availability(from: termModel.availability)
    }

    struct Availability: Hashable, Codable, Sendable {
        let isAvailable: Bool
        let duration: Availability.Duration

        init(from termAvailabilityModel: Term.Availability) {
            self.isAvailable = termAvailabilityModel.isAvailable
            self.duration = Availability.Duration(from: termAvailabilityModel.duration)
        }

        enum Duration: Hashable, Codable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDays(_ days: Int)

            init(from termAvailabilityDurationModel: Term.Availability.Duration) {
                switch termAvailabilityDurationModel {
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
