//
//  TimetableWidgetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/09/2025.
//

import SwiftUI
import WidgetKit
import Timetable
import TimetableUI
import LearnKit

fileprivate let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    formatter.locale = Locale.current

    return formatter
}()

struct SmallTimetableRowView: View {
    private var scheduledClass: ScheduledClass
    private var displayColourBar: Bool

    init(_ scheduledClass: ScheduledClass, displayColourBar: Bool = true) {
        self.scheduledClass = scheduledClass
        self.displayColourBar = displayColourBar
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                if displayColourBar {
                    Color("AccentColor")
                        .frame(maxWidth: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 1000))
                }

                VStack(alignment: .leading) {
                    Text(scheduledClass.name)
                        .lineLimit(1)
                        .font(.subheadline.bold())
                    // Don't ask me why they formatted the locations like this
                    Text(scheduledClass.location.replacingOccurrences(of: "\\", with: ""))
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                    //.foregroundStyle(appearance == .app ? .brightonSecondary : .secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("at \(timeFormatter.string(from: scheduledClass.startDate))")
                        .font(.caption)
                    Text("ends \(timeFormatter.string(from: scheduledClass.endDate))")
                        .foregroundStyle(.brightonSecondary)
                        .font(.caption)
                }
                .frame(minWidth: 91, alignment: .trailing)
            }
            .fixedSize(horizontal: false, vertical: true)

            HStack {
                if displayColourBar {
                    Color("AccentColor")
                        .frame(maxWidth: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 1000))
                }

                VStack(alignment: .leading) {
                    Text(scheduledClass.name)
                        .lineLimit(1)
                        .font(.subheadline.bold())
                    Text("\(timeFormatter.string(from: scheduledClass.startDate))-\(timeFormatter.string(from: scheduledClass.endDate))")
                        .font(.caption)
                    // Don't ask me why they formatted the locations like this
                    Text(scheduledClass.location.replacingOccurrences(of: "\\", with: ""))
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                    //.foregroundStyle(appearance == .app ? .brightonSecondary : .secondary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ExtraLargeTimetableRowView: View {
    private var scheduledClass: ScheduledClass

    init(_ scheduledClass: ScheduledClass) {
        self.scheduledClass = scheduledClass
    }

    var body: some View {
        HStack {
            Color("AccentColor")
                .frame(maxWidth: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1000))

            VStack(alignment: .leading) {
                Text(scheduledClass.name)
                    .font(.largeTitle.bold())
                Text("\(timeFormatter.string(from: scheduledClass.startDate))-\(timeFormatter.string(from: scheduledClass.endDate))")
                // Don't ask me why they formatted the locations like this
                Text(scheduledClass.location.replacingOccurrences(of: "\\", with: ""))
                    .foregroundStyle(.secondary)
                //.foregroundStyle(appearance == .app ? .brightonSecondary : .secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct TimetableWidgetView: View {
    @Environment(\.widgetContentMargins) private var widgetMargins
    @Environment(\.widgetFamily) private var sizeFamily

    var entry: TimetableWidgetProvider.Entry

    private var isShowingTomorrow: Bool {
        if let firstClass = entry.classes.first, firstClass.startDate.withoutTime != .now.withoutTime {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        Group {
            if entry.classes.isEmpty {
                NoContentView {
                    Text(entry.hadClassesToday ? "Classes Finished for Today" : "No Classes Today")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            } else {
                Group {
                    switch sizeFamily {
                        case .systemSmall:
                            SmallTimetableWidgetView(entry: entry)
                        case .systemMedium:
                            MediumTimetableWidgetView(entry: entry)
                        case .systemLarge:
                            verticalList(Array(entry.classes.prefix(5)))
                                .padding(widgetMargins)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        case .systemExtraLarge:
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    widgetTitle
                                        .font(.headline)
                                    ExtraLargeTimetableRowView(entry.classes.first!)
                                }
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Later")
                                        .font(.headline)
                                    let classes = Array(entry.classes.dropFirst().prefix(4))
                                    verticalList(classes)
                                }
                            }
                            .padding(widgetMargins)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        case .accessoryCircular:
                            Text("No Content")
                        case .accessoryRectangular:
                            SmallTimetableRowView(entry.classes.first!, displayColourBar: false)
                                .padding(widgetMargins)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        case .accessoryInline:
                            Text("No Content")
                        @unknown default:
                            Text("No Content")
                    }
                }
                .widgetBorder()
            }
        }
        .widgetBackground()
    }

    func verticalList(_ classes: [ScheduledClass]) -> some View {
        VStack(alignment: .leading) {
            ForEach(classes, id: \.id) { scheduledClass in
                SmallTimetableRowView(scheduledClass)
            }
        }
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
                location: "Moulsecoomb, Cockroft G20",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 11),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
                moduleCode: "CI512"
            ),
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

#Preview("No Classes Today", as: .systemSmall) {
    TimetableWidget()
} timeline: {
    TimetableWidgetProviderEntry(
        date: .now.withoutTime,
        relevance: .init(score: 0),
        classes: [],
        hadClassesToday: false
    )
}


#Preview("Classes Finished for Today", as: .systemSmall) {
    TimetableWidget()
} timeline: {
    TimetableWidgetProviderEntry(
        date: .now.withoutTime,
        relevance: .init(score: 0),
        classes: [],
        hadClassesToday: true
    )
}
