//
//  MyBrightonAppShortcutsProvider.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//

import LearnKit
import AppIntents
import TimetableIntents

final class MyBrightonAppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetTimetableIntent(date: .now),
            phrases: [
                "What are my classes in \(.applicationName)",
                "What is my timetable in \(.applicationName)"
            ],
            shortTitle: "Today's Classes",
            systemImageName: "calendar.day.timeline.leading"
        )

        AppShortcut(
            intent: OpenCourseIntent(),
            phrases: [
                "Open \(\.$target) in \(.applicationName)",
                "Open \(\.$target) course in \(.applicationName)"
            ],
            shortTitle: "Open Course",
            systemImageName: "book",
            parameterPresentation: ParameterPresentation(
                for: \.$target,
                summary: Summary("Open \(\.$target)"),
                optionsCollections: {
                    OptionsCollection(FavouriteCourseEntityQuery(), title: "Favourite Courses", systemImageName: "star")
                    OptionsCollection(CourseEntityQuery(), title: "Current Courses", systemImageName: "book")
                }
            )
        )
    }
}
