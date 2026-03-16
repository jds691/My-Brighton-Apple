//
//  ScheduledClassEntityQuery.swift
//  My Brighton
//
//  Created by Neo Salmon on 22/08/2025.
//

import AppIntents

public struct ScheduledClassEntityQuery: EntityQuery {
    @Dependency
    private var timetableService: TimetableService

    public init() {
        
    }

    public func entities(for identifiers: [ScheduledClass.ID]) async throws -> [Entity] {
        return try await timetableService.getClasses(from: identifiers).map { ScheduledClassEntity(from: $0) }
    }

    public typealias Entity = ScheduledClassEntity
}
