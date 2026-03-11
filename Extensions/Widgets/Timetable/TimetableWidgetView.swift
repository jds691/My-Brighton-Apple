//
//  TimetableWidgetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/09/2025.
//

import SwiftUI
import WidgetKit
import Timetable
import LearnKit
import CoreDesign

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
    @Environment(\.showsWidgetContainerBackground) private var showsBackground

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
                if showsBackground {
                    NoContentView {
                        Text(entry.hadClassesToday ? "Classes Finished for Today" : "No Classes Today")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Timetable")
                            .bold()
                        Text(entry.hadClassesToday ? "Classes Finished for Today" : "No Classes Today")
                            .foregroundStyle(.secondary)
                    }
                    .padding(widgetMargins)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            } else {
                Group {
                    switch sizeFamily {
                        case .systemSmall:
                            SmallTimetableWidgetView(entry: entry)
                        case .systemMedium:
                            MediumTimetableWidgetView(entry: entry)
                        case .systemLarge:
                            LargeTimetableWidgetView(entry: entry)
                        case .systemExtraLarge:
                            Text("No Content")
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
