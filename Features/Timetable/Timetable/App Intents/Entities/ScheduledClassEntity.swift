//
//  ScheduledClassEntity.swift
//  My Brighton
//
//  Created by Neo Salmon on 22/08/2025.
//

import AppIntents

public struct ScheduledClassEntity: TransientAppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Scheduled Class")
    }

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)", subtitle: "\(location)")
    }

    public var id: String

    @Property(title: "Name")
    public var name: String
    @Property(title: "Location")
    public var location: String
    @Property(title: "Start Date")
    public var startDate: Date
    @Property(title: "End Date")
    public var endDate: Date
    @Property(title: "Module Code")
    public var moduleCode: String

    public init() {
        self.id = ""
    }

    public init(from modelClass: ScheduledClass) {
        self.id = modelClass.id
        self.name = modelClass.name
        self.location = modelClass.location
        self.startDate = modelClass.startDate
        self.endDate = modelClass.endDate
        self.moduleCode = modelClass.moduleCode
    }
}
