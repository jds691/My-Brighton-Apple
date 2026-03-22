//
//  ScheduledClassInfo.swift
//  Notifier
//
//  Created by Neo Salmon on 22/03/2026.
//

import Foundation

public struct ScheduledClassInfo: Identifiable {
    public let id: String
    public let name: String
    public let location: String
    public let startDate: Date

    public init(id: String, name: String, location: String, startDate: Date) {
        self.id = id
        self.name = name
        self.location = location
        self.startDate = startDate
    }
}
