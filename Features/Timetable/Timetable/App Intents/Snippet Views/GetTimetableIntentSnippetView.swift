//
//  GetTimetableIntentSnippetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/08/2025.
//

import SwiftUI

public struct GetTimetableIntentSnippetView: View {
    private var entities: [ScheduledClassEntity]
    private var upcomingOrLaterEntities: [ScheduledClassEntity]? = nil

    public init(_ entities: [ScheduledClassEntity]) {
        self.entities = entities

        guard let lastEndDate = entities.last?.endDate else { return }

        // Still classes left TODAY
        if lastEndDate.withoutTime == .now.withoutTime && lastEndDate > .now {
            upcomingOrLaterEntities = entities.filter({ $0.endDate >= .now })
        }
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if let upcomingOrLaterEntities {
                Text("Up Next")
                    .bold()
                TimetableRowView(upcomingOrLaterEntities.first!, prominent: true)
                    .appearance(.intents)

                let evenLaterClasses = upcomingOrLaterEntities.dropFirst()

                Text("Later")
                    .bold()

                if evenLaterClasses.isEmpty {
                    Text("Classes Finished for Today")
                        .font(.caption)
                } else {
                    HStack {
                        HStack(spacing: 4) {
                            ForEach(evenLaterClasses, id: \.id) { entity in
                                // TODO: Look up colour from LearnKit
#if os(macOS)
                                Color(nsColor: NSColor(named: "AccentColor")!)
                                    .frame(maxWidth: 3)
                                    .clipShape(RoundedRectangle(cornerRadius: 1000))
#else
                                Color(uiColor: UIColor(named: "AccentColor")!)
                                    .frame(maxWidth: 3)
                                    .clipShape(RoundedRectangle(cornerRadius: 1000))
#endif
                            }
                        }

                        Text("\(evenLaterClasses.count - 1) more classes later")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                // TODO: Can badly overflow even with only 3 classes
                ForEach(entities, id: \.id) { scheduledClass in
                    TimetableRowView(scheduledClass)
                        .appearance(.intents)
                }
            }
        }
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .scenePadding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.brightonBackground)
                    .clipShape(ContainerRelativeShape())
                    .scenePadding([.horizontal, .top])
                    .foregroundStyle(.primary, .brightonSecondary)
            } else {
                $0
                    .scenePadding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 402, height: 340)) {
    GetTimetableIntentSnippetView([
        .init(
            from: .init(
                id: UUID().uuidString,
                name: "Intelligent Systems 1",
                location: "G20",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 11),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
                moduleCode: "CI401"
            )
        ),
        .init(
            from: .init(
                id: UUID().uuidString,
                name: "Data Structures and Operating Systems",
                location: "Mithras G8",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 13),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                moduleCode: "CI401"
            )
        ),
        .init(
            from: .init(
                id: UUID().uuidString,
                name: "Embedded Systems",
                location: "C207",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 17),
                moduleCode: "CI401"
            )
        ),
        .init(
            from: .init(
                id: UUID().uuidString,
                name: "Embedded Systems",
                location: "C207",
                startDate: .now.withoutTime.addingTimeInterval(60 * 60 * 15),
                endDate: .now.withoutTime.addingTimeInterval(60 * 60 * 17),
                moduleCode: "CI401"
            )
        )
    ])
}
