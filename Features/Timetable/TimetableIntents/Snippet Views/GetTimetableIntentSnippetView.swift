//
//  GetTimetableIntentSnippetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/08/2025.
//

import SwiftUI
import Timetable
import TimetableUI

public struct GetTimetableIntentSnippetView: View {
    private var entities: [ScheduledClassEntity]

    public init(_ entities: [ScheduledClassEntity]) {
        self.entities = entities
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Up Next")
                .font(.title3.bold())
            TimetableRowView(entities.first!, prominent: true)
                .appearance(.system)

            if entities.count > 1 {
                Text("After")
                    .font(.title3.bold())
                HStack {
                    HStack(spacing: 4) {
                        ForEach(entities.dropFirst(1), id: \.id) { entity in
                            //Color("Course Colour/\(entity.colourIndex)")
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

                    Text("\(entities.count - 1) more classes later")
                        .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
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
