//
//  ExtraClassesView.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/10/2025.
//

import SwiftUI
import Timetable

struct ExtraClassesView: View {
    private var scheduledClasses: [ScheduledClass]

    init(_ scheduledClasses: [ScheduledClass]) {
        self.scheduledClasses = scheduledClasses
    }

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(scheduledClasses, id: \.id) { entity in
                    //Color("Course Colour/\(entity.colourIndex)")
                    // TODO: Look up colour from LearnKit
                    Color("AccentColor")
                        .frame(maxWidth: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 1000))
                }
            }

            Text("timetable.\(scheduledClasses.count).classes.later")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
