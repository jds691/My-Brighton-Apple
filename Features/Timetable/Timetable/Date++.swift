//
//  Date++.swift
//  My Brighton
//
//  Created by Neo Salmon on 22/08/2025.
//

import Foundation

public extension Date {
    /// Sets the time of the date to midnight and returns a new instance.
    ///
    /// This extension automatically accounts for time zones.
    var withoutTime: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)

        if (TimeZone.current.isDaylightSavingTime()) {
            components.hour = Int(TimeZone.current.daylightSavingTimeOffset()) / 3600
        }

        guard let date = Calendar.current.date(from: components) else {
            fatalError("Failed to strip time from Date object")
        }

        return date
    }
}
