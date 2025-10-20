//
//  TimetableRowView.swift
//  My Brighton
//
//  Created by Neo Salmon on 30/08/2025.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Timetable

/// A view that renders a scheduled class into a row.
public struct TimetableRowView: View {
    private var scheduledClass: ScheduledClass
    private var isProminent: Bool
    private var appearance: Appearance = .app

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        return formatter
    }()
    
    /// Initialises a new view from a scheduled class instance.
    /// - Parameters:
    ///   - scheduledClass: The class to render into the view.
    ///   - prominent: Indicates if the view should take a larger more prominent appearance.
    public init(_ scheduledClass: ScheduledClass, prominent: Bool = false) {
        self.scheduledClass = scheduledClass
        self.isProminent = prominent
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Has to be like this for App Intents idk why
            // TODO: Look up colour correctly from LearnKit
#if os(macOS)
            //Color(nsColor: NSColor(named: "Course Colour/\(scheduledClass.colourIndex)")!)
            Color(nsColor: NSColor(named: "AccentColor")!)
                .frame(maxWidth: isProminent ? 6 : 3)
                .clipShape(RoundedRectangle(cornerRadius: 1000))
#else
            //Color(uiColor: UIColor(named: "Course Colour/\(scheduledClass.colourIndex)")!)
            Color(uiColor: UIColor(named: "AccentColor")!)
                .frame(maxWidth: isProminent ? 6 : 3)
                .clipShape(RoundedRectangle(cornerRadius: 1000))
#endif
            VStack(alignment: .leading, spacing: 4) {
                Text(scheduledClass.name)
                    .lineLimit(2)
                    .font(isProminent ? .title.bold() : .headline)
                // Don't ask me why they formatted the locations like this
                Text(scheduledClass.location.replacingOccurrences(of: "\\", with: ""))
                    .lineLimit(2)
                //.foregroundStyle(appearance == .app ? Color("BrightonSecondary") : .secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("at \(timeFormatter.string(from: scheduledClass.startDate))")
                Text("ends \(timeFormatter.string(from: scheduledClass.endDate))")
                    //.foregroundStyle(.secondary)
                    .foregroundStyle(appearance == .app ? Color("BrightonSecondary") : .secondary)
            }
            .frame(minWidth: 91, alignment: .trailing)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Represents the different styles this view can appear as.
    public enum Appearance {
        /// Adjusts the appearance to match the My Brighton app theme.
        case app
        /// Adjusts the appearance to match system components.
        case system
    }
}

public extension TimetableRowView {
    /// Adjust the appearance of the ``TimetableRowView`` to match a given style.
    /// - Parameter style: The style the view should adopt.
    /// - Returns: Styled instance of the view.
    func appearance(_ style: Self.Appearance) -> Self {
        var view = self
        view.appearance = style
        return view
    }
}

#Preview("Regular", traits: .sizeThatFitsLayout) {
    TimetableRowView(
        .init(
            id: UUID().uuidString,
            name: "Embedded Systems",
            location: "C207",
            startDate: .now,
            endDate: Date.distantFuture,
            moduleCode: "CI402"
        )
    )
}

#Preview("Prominent", traits: .sizeThatFitsLayout) {
    TimetableRowView(
        .init(
            id: UUID().uuidString,
            name: "Embedded Systems",
            location: "C207",
            startDate: .now,
            endDate: Date.distantFuture,
            moduleCode: "CI402"
        ),
        prominent: true
    )
}
