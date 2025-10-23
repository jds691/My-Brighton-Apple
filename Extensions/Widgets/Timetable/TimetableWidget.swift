//
//  TimetableWidget.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/09/2025.
//

import SwiftUI
import WidgetKit
import Timetable
import AppIntents

struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"

    private var supportedFamilies: [WidgetFamily] = {
        var families: [WidgetFamily] = [
            .systemSmall,
            .systemMedium,
            .systemLarge
        ]


        #if os(iOS)
        families.append(.accessoryRectangular)
        #endif

        return families
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimetableWidgetProvider()) { entry in
            TimetableWidgetView(entry: entry)
                .widgetURL(URL(string: "mybrighton://home/timetable")!)
        }
        .configurationDisplayName("timetable.widget.name")
        .description(Text("timetable.widget.description"))
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}

// TODO: Make multiple updates or whatever is needed to display "Now" instead of "Up Next" during a class
struct TimetableWidgetProvider: TimelineProvider {
    typealias Entry = TimetableWidgetProviderEntry

    let service = TimetableService()

    func placeholder(in context: Context) -> TimetableWidgetProviderEntry {
        return TimetableWidgetProviderEntry(
            date: .now.withoutTime,
            relevance: .init(score: 0),
            classes: [
                .init(
                    id: "CI512",
                    name: "Intelligent Systems 1",
                    location: "G20",
                    startDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 11)),
                    endDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 13)),
                    moduleCode: "CI512"
                ),
                .init(
                    id: "CI583",
                    name: "Data Structures and Operating Systems",
                    location: "Mithras G8",
                    startDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 13)),
                    endDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 15)),
                    moduleCode: "CI583"
                ),
                .init(
                    id: "CI514",
                    name: "Embedded Systems",
                    location: "C207",
                    startDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 15)),
                    endDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 17)),
                    moduleCode: "CI514"
                )
            ],
            hadClassesToday: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (TimetableWidgetProviderEntry) -> Void) {
        // TODO: Implement properly
        completion(
            TimetableWidgetProviderEntry(
                date: .now.withoutTime,
                relevance: .init(score: 0),
                classes: [
                    .init(
                        id: "CI512",
                        name: "Intelligent Systems 1",
                        location: "G20",
                        startDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 11)),
                        endDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 13)),
                        moduleCode: "CI512"
                    ),
                    .init(
                        id: "CI583",
                        name: "Data Structures and Operating Systems",
                        location: "Mithras G8",
                        startDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 13)),
                        endDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 15)),
                        moduleCode: "CI583"
                    ),
                    .init(
                        id: "CI514",
                        name: "Embedded Systems",
                        location: "C207",
                        startDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 15)),
                        endDate: .now.withoutTime.addingTimeInterval(TimeInterval(60 * 60 * 17)),
                        moduleCode: "CI514"
                    )
                ],
                hadClassesToday: true
            )
        )
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<TimetableWidgetProviderEntry>) -> Void) {
        // Wrapping the entire function body in a task counted as misuse and prevented widgets loading
        Task {
            let todaysClasses = try await service.getClasses(after: .now.withoutTime)
            let tomorrowClasses = try await service.getClasses(after: .now.withoutTime.addingTimeInterval(86400))

            var entries: [Entry] = []

            if !todaysClasses.isEmpty {
                let relevance = TimelineEntryRelevance(score: Entry.Relevance.startOfDay.rawValue)
                entries.append(.init(date: .now.withoutTime, relevance: relevance, classes: todaysClasses, hadClassesToday: true))

                for index in todaysClasses.indices.dropFirst() {
                    let updateRelevance = TimelineEntryRelevance(score: Entry.Relevance.update.rawValue)
                    entries.append(.init(date: todaysClasses[index - 1].endDate, relevance: updateRelevance, classes: Array(todaysClasses.dropFirst(index)), hadClassesToday: true))
                }

                let noMoreClassesRelevance = TimelineEntryRelevance(score: Entry.Relevance.update.rawValue)
                entries.append(.init(date: todaysClasses.last!.endDate, relevance: noMoreClassesRelevance, classes: [], hadClassesToday: true))

                if !tomorrowClasses.isEmpty {
                    let updateRelevance = TimelineEntryRelevance(score: Entry.Relevance.startOfDay.rawValue)
                    entries.append(.init(date: todaysClasses.last!.endDate, relevance: updateRelevance, classes: tomorrowClasses, hadClassesToday: true))
                }
            } else {
                entries.append(.init(date: .now.withoutTime, relevance: TimelineEntryRelevance(score: Entry.Relevance.startOfDay.rawValue), classes: [], hadClassesToday: false))
            }

            // Adds 1 day in seconds
            completion(Timeline(entries: entries, policy: .after(.now.withoutTime.addingTimeInterval(86400))))
        }
    }
}

struct TimetableWidgetProviderEntry: TimelineEntry {
    let date: Date
    let relevance: TimelineEntryRelevance
    let classes: [ScheduledClass]
    let hadClassesToday: Bool

    enum Relevance: Float {
        case update = 0.0
        case startOfDay = 50.0
        /// Represents an entry that alerts the user of a cancelled class.
        ///
        /// **Reserved field**. The TimetableService cannot detect cancelled classes.
        case cancelledClass = 100.0
    }
}
