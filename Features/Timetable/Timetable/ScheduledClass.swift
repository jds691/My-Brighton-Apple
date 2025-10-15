//
//  ScheduledClass.swift
//  My Brighton
//
//  Created by Neo Salmon on 29/08/2025.
//

import Foundation
import MXLCalendarManagerSwift

/// Represents  a timetabled class the user is scheduled to attend.
public struct ScheduledClass: Identifiable, Hashable, Sendable {
    /// The unique identifier for the original event of this class.
    ///
    /// Corresponds to iCalendar `UID:`.
    public internal(set) var id: String
    /// The name of the class.
    ///
    /// Corresponds to iCalendar `SUMMARY:`.
    public internal(set) var name: String
    /// The location of the class.
    ///
    /// Corresponds to iCalendar `LOCATION:`.
    public internal(set) var location: String
    /// The time the class starts at.
    ///
    /// Corresponds to iCalendar `DTSTART:`.
    public internal(set) var startDate: Date
    /// The time the class ends at.
    ///
    /// Corresponds to iCalendar `DTEND:`.
    public internal(set) var endDate: Date
    /// The module code for the class.
    ///
    /// This is extracted from the iCalendar `DESCRIPTION:` property.
    ///
    /// Valid module codes are recognised as:
    /// - Starting with 2 letters, ending with 3 numbers, 5 characters long.
    /// - Starting with 3 letters, ending with 2 numbers, 5 characters long.
    public internal(set) var moduleCode: String

    /// Creates a scheduled class from its main components.
    /// - Parameters:
    ///   - id: Unique identifier for the class.
    ///   - name: The name of the class.
    ///   - location: The room and building the class is in.
    ///   - startDate: Time the class starts at.
    ///   - endDate: Time the class ends at.
    ///   - moduleCode: Module code for the class.
    public init(id: String, name: String, location: String, startDate: Date, endDate: Date, moduleCode: String) {
        self.id = id
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.moduleCode = moduleCode
    }
    
    /// Creates a scheduled class from a parsed iCalendar event.
    /// - Parameter event: Parsed iCalendar event.
    init(from event: MXLCalendarEvent) {
        self.id = event.eventUniqueID ?? UUID().uuidString
        self.name = event.eventSummary ?? "Unknown Class"
        if let location = event.eventLocation {
            self.location = location.isEmpty ? "No Location" : location
        } else {
            self.location = "No Location"
        }

        self.startDate = event.eventStartDate ?? Date.distantFuture
        self.endDate = event.eventEndDate ?? Date.distantFuture
        // TODO: Figure out how to locate the colour
        /*
         Some ideas:
         - The event categories list the module code e.g. CI401. Could cross match with LearnKit and only take results from the current Bb term?
            - **This excludes non standard classes e.g. Belong at Brighton doesn't have a module code**
            - Module codes have no properly defined format e.g. BEM09 is a valid module code
                - Module code requirements?
                    - Starts with 2-3 upper case letters
                    - If 2 letters it ends in 3 numbers (let twoLetterModuleCodeRegex = try! Regex("(?:\\w{2})(?:\\d{3}+$)"))
                    - If 3 letters it ends in 2 numbers (let threeLetterModuleCodeRegex = try! Regex("(?:\\w{3})(?:\\d{2}+$)"))
         */

        // TODO: I have no idea why it's like *this* now but eh
        let descriptionComponents = (event.eventDescription ?? "").split(separator: " n")

        let twoLetterModuleCodeRegex = try! Regex("(?:\\w{2})(?:\\d{3}+$)")
        let threeLetterModuleCodeRegex = try! Regex("(?:\\w{3})(?:\\d{2}+$)")

        for component in descriptionComponents {
            let formattedComponent = component.trimmingCharacters(in: .whitespaces)

            if try! twoLetterModuleCodeRegex.wholeMatch(in: formattedComponent) != nil || threeLetterModuleCodeRegex.wholeMatch(in: formattedComponent) != nil {
                print("Found module code: \(formattedComponent)")
                self.moduleCode = formattedComponent
                return
            }
        }

        print("Unable to find module code")
        self.moduleCode = ""
    }
}
