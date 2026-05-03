//
//  GetCourseAnnouncementsIntent.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/02/2026.
//

import AppIntents

public struct GetCourseAnnouncementsIntent: AppIntent {
    public static let title: LocalizedStringResource = "Get Course Announcements"
    public static let description: IntentDescription? = IntentDescription("Gets all announcements for the chosen course", resultValueName: "Announcements")

    @Dependency
    private var learnKit: LearnKitService

    @Parameter(description: "Course to get announcements for")
    public var course: CourseEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Get Announcements for \(\.$course)")
    }

    public init() {}

    public func perform() async throws -> some IntentResult & ReturnsValue<[CourseAnnouncementEntity]> {
        return try await .result(
            value: learnKit
                .getAllCourseAnnouncements(for: course.id)
                .sorted(by: { $0.positionIndex < $1.positionIndex })
                .map { CourseAnnouncementEntity(from: $0, course: course.id) }
        )
    }
}
