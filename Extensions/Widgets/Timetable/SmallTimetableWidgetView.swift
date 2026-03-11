//
//  SmallTimetableWidgetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/10/2025.
//

import SwiftUI
import WidgetKit
import Timetable
import CoreDesign

fileprivate let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    formatter.locale = Locale.current

    return formatter
}()

struct SmallTimetableWidgetView: View {
    @Environment(\.widgetContentMargins) private var widgetMargins

    var entry: TimetableWidgetProvider.Entry

    private var isShowingTomorrow: Bool {
        if let firstClass = entry.classes.first, firstClass.startDate.withoutTime != .now.withoutTime {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            VStack(alignment: .leading) {
                widgetTitle
                    .font(.headline)

                let scheduledClass = entry.classes.first!
                HStack {
                    Color("AccentColor")
                        .frame(maxWidth: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 1000))
                        .widgetAccentable()

                    VStack(alignment: .leading) {
                        Text(scheduledClass.name)
                            .lineLimit(1)
                            .font(.subheadline.bold())
                        Text("\(timeFormatter.string(from: scheduledClass.startDate))-\(timeFormatter.string(from: scheduledClass.endDate))")
                            .font(.caption)
                        // Don't ask me why they formatted the locations like this
                        Text(scheduledClass.location.replacingOccurrences(of: "\\", with: ""))
                            .font(.caption)
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                            .foregroundStyle(.brightonSecondary)
                        //.foregroundStyle(appearance == .app ? .brightonSecondary : .secondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                let remainingClasses = Array(entry.classes.dropFirst())

                if !remainingClasses.isEmpty {
                    ExtraClassesView(remainingClasses)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                widgetTitle
                    .font(.headline)

                let scheduledClass = entry.classes.first!
                HStack {
                    Color("AccentColor")
                        .frame(maxWidth: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 1000))

                    VStack(alignment: .leading) {
                        Text(scheduledClass.name)
                            .lineLimit(1)
                            .font(.subheadline.bold())
                        Text("\(timeFormatter.string(from: scheduledClass.startDate))-\(timeFormatter.string(from: scheduledClass.endDate))")
                            .font(.caption)

                        Text(scheduledClass.location.replacingOccurrences(of: "\\", with: ""))
                            .font(.caption)
                            .minimumScaleFactor(0.5)
                            .lineLimit(3)
                            .foregroundStyle(.secondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(widgetMargins)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var widgetTitle: some View {
        Text(
            isShowingTomorrow ? "timetable.tomorrow.label" : "timetable.up-next.label",
            comment: "Indicates what state the widget it in. Is it displaying today's classes or previewing tomorrows?"
        )
    }
}

#Preview(as: .systemSmall) {
    TimetableWidget()
} timeline: {
    TimetableWidgetProviderEntry(
        date: .now.withoutTime,
        relevance: .init(score: 0),
        classes: [
            .init(
                id: "CI512",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Cockroft G20 - Software Lab Suite",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 11),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
                moduleCode: "CI512"
            ),
            .init(
                id: "CI583",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Mithras G8 - Software Lab Suite",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                moduleCode: "CI583"
            ),
            .init(
                id: "CI514",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Cockroft 207",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 17),
                moduleCode: "CI514"
            ),
            /*.init(
             id: "CI512",
             name: "Data Structures and Operating Systems",
             location: "G20",
             date: .now.withoutTime.addingTimeInterval(60 * 60 * 11),
             moduleCode: "CI512"
             ),
             .init(
             id: "CI583",
             name: "Data Structures and Operating Systems",
             location: "Mithras G8",
             date: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
             moduleCode: "CI583"
             ),
             .init(
             id: "CI514",
             name: "Data Structures and Operating Systems",
             location: "C207",
             date: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
             moduleCode: "CI514"
             )*/
        ],
        hadClassesToday: true
    )
    TimetableWidgetProviderEntry(
        date: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
        relevance: .init(score: 0),
        classes: [
            .init(
                id: "CI583",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Mithras G8",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                moduleCode: "CI583"
            ),
            .init(
                id: "CI514",
                name: "Embedded Systems",
                location: "Moulsecoomb, Cockroft 207",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 17),
                moduleCode: "CI514"
            )
        ],
        hadClassesToday: true
    )
    TimetableWidgetProviderEntry(
        date: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
        relevance: .init(score: 0),
        classes: [
            .init(
                id: "CI514",
                name: "Embedded Systems",
                location: "Moulsecoomb, Cockroft 207",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 17),
                moduleCode: "CI514"
            )
        ],
        hadClassesToday: true
    )
    TimetableWidgetProviderEntry(
        date: .now.withoutTime.addingTimeInterval(60 * 60 * 17),
        relevance: .init(score: 0),
        classes: [
            .init(
                id: "CI512",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Cockroft G20",
                startDate: .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 11),
                endDate: .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 13),
                moduleCode: "CI512"
            ),
            .init(
                id: "CI583",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Mithras G8",
                startDate: .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 13),
                endDate: .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 15),
                moduleCode: "CI583"
            ),
            .init(
                id: "CI514",
                name: "Data Structures and Operating Systems",
                location: "Moulsecoomb, Cockroft 207",
                startDate: .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 15),
                endDate: .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 17),
                moduleCode: "CI514"
            )
        ],
        hadClassesToday: true
    )
}
