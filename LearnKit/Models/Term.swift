//
//  Term.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/10/2025.
//

import Foundation

public struct Term: Hashable, Identifiable, Sendable {
    public let id: String
    public let externalId: String
    public let dataSourceId: String
    public let name: String
    public let description: String
    public let availability: Term.Availability

    public struct Availability: Hashable, Sendable {
        public let isAvailable: Bool
        public let duration: Availability.Duration

        public enum Duration: Hashable, Sendable {
            case continuous
            case dateRange(start: Date, end: Date)
            case numberOfDays(_ days: Int)
        }
    }
}
