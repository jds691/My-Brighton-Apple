//
//  CourseAnnouncementEntityQuery.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/02/2026.
//

import AppIntents

public struct CourseAnnouncementEntityQuery: EntityQuery {
    @AppDependency
    private var learnKit: LearnKitService

    @IntentParameterDependency<GetCourseAnnouncementsIntent>(
        \.$course
    )
    var getCourseAnnouncements

    public init() {

    }

    public func entities(for identifiers: [CourseAnnouncement.ID]) async throws -> [Entity] {
        guard let projection = getCourseAnnouncements else { throw LearnKitError.unknown(statusCode: nil) }

        var announcementIds: [CourseAnnouncement.ID] = []
        for identifier in identifiers {
            let parts = identifier.split(separator: "/")
            guard parts.count == 2 else { continue }

            guard parts[0] == projection.course.id else { continue }
            announcementIds.append(String(parts[1]))
        }

        return try await learnKit.getAllCourseAnnouncements(for: projection.course.id)
            .filter { announcementIds.contains($0.id) }
            .map { CourseAnnouncementEntity(from: $0, course: projection.course.id) }

    }

    public func suggestedEntities() async throws -> [Entity] {
        guard let projection = getCourseAnnouncements else { throw LearnKitError.unknown(statusCode: nil) }

        return try await learnKit.getAllCourseAnnouncements(for: projection.course.id)
            .map { CourseAnnouncementEntity(from: $0, course: projection.course.id) }
    }

    public typealias Entity = CourseAnnouncementEntity
}
