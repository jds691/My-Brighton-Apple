//
//  TimetableService.swift
//  My Brighton
//
//  Created by Neo Salmon on 29/08/2025.
//

import Foundation
import os
import MXLCalendarManagerSwift
import UserNotifications
import BackgroundTasks
import WidgetKit
import Notifier

/// The service responsible for reading the users timetable and performing related activities.
public final class TimetableService: @unchecked Sendable {
    /// The ``/Foundation/UserDefaults`` key that the service expects to read the users timetable from.
    ///
    /// The service will internally read the URL from ``/Foundation/UserDefaults/url(forKey: String)`` and therefore the URL should be set using either of the following:
    ///
    /// - ``/Foundation/UserDefaults/setValue(_: Any?, forKey: String)`` where the value is a `URL?` type and the key is this key.
    /// - An ``/SwiftUI/AppStorage`` property wrapper using this key with the type `URL?`.
    public static let remoteURLUserDefaultsKey: String = "Timetable.remoteURL"

    private static let logger: Logger = Logger(subsystem: "com.neo.My-Brighton", category: "TimetableService")

    private let notifier: Notifier?

    private var remoteIcsURL: URL? = nil
    private var calendar: MXLCalendar?
    private var calendarDownloadTask: Task<Void, any Swift.Error>?

    private let icsCacheURLPath: String = {
        let filePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton")!.appending(path: "Library/Caches").appending(path: "calendar.ics").path(percentEncoded: false)

        return filePath
    }()


    /// Indicates if the service can in-theory read the users timetable.
    ///
    /// This is determined by either:
    /// - If the remote URL is set
    /// - A cached calendar.ics file is found
    public var canFetchTimetable: Bool {
        remoteIcsURL != nil || FileManager.default.fileExists(atPath: icsCacheURLPath)
    }

    /// Initialises an instance of the service with no data.
    ///
    /// During initialisation the service will attempt to read the users remote URL for the timetable from ``/Foundation/UserDefaults`` by the key ``remoteURLUserDefaultsKey``.
    ///
    /// It is expected to be stored in the App Group: `group.com.neo.My-Brighton`
    public init(notifier: Notifier?) {
        calendar = nil
        calendarDownloadTask = nil
        remoteIcsURL = UserDefaults(suiteName: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton")!.url(forKey: Self.remoteURLUserDefaultsKey)
        self.notifier = notifier
    }
    
    /// Initialises an instance of the service using preview data.
    /// - Parameter previewData: Raw data stream of a valid iCalendar file.
    ///
    /// >important: Some instance methods may not function correctly as this initialiser does not load or set a remote URL by default. If this functionality is desired, set the remote URL with ``setRemoteURL(_:)``.
    public init(from previewData: Data) {
        self.notifier = nil
        let icsString: String = cleanIcsString(String(decoding: previewData, as: UTF8.self))

        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            calendar = try await MXLCalendarManager().parse(icsString: icsString)
        }

        semaphore.wait()
        calendarDownloadTask = nil
    }

    private func initialiseCalendar() async throws {
        if let calendarDownloadTask {
            Self.logger.debug("\(#function) called while initialisation task is already in progress, awaiting...")
            if case .failure(let error) = await calendarDownloadTask.result {
                throw error
            }
        } else {
            calendarDownloadTask = Task {
                defer { calendarDownloadTask = nil }

                let fileData: Data

                if FileManager.default.fileExists(atPath: icsCacheURLPath) {
                    fileData = loadCalendarDataFromCache()
                } else if remoteIcsURL != nil {
                    fileData = try await downloadRemoteTimetable()
                } else {
                    throw TimetableService.Error.noTimetableSpecified
                }

                let icsString: String = String(decoding: fileData, as: UTF8.self)

                calendar = try await MXLCalendarManager().parse(icsString: cleanIcsString(icsString))
            }

            if case .failure(let error) = await calendarDownloadTask!.result {
                throw error
            }
        }
    }
    
    /// Returns a list classes the user is scheduled to attend on or after the given date.
    ///
    /// The date passed in time sensitive meaning that only classes occuring at the given time or beyond it will be returned.
    ///
    /// To get all classes the user was scheduled for on the given date, pass an instance of the date in with the ``Foundation/Date/withoutTime`` extension property.
    ///
    /// >important: This method will automatically initialise the calendar used by the service if it has not already been initialised.
    /// - Parameter date: Minimum date a class can be scheduled for.
    /// - Returns: List of classes the user is scheduled for on or after the given date.
    public func getClasses(after date: Date) async throws -> [ScheduledClass] {
        if let calendar {
            // 86400 = 1 day in seconds
            var events = [ScheduledClass]()
            for event in calendar.events {
                // TODONT: The check fails if the times don't match *IF* the event is not a recurrence e.g. the first event defined for the rule

                // This checks handles the fact that the library does not match events that start on the date passed in
                if let startDate = event.eventStartDate, startDate >= date && startDate < date.withoutTime.addingTimeInterval(86400) {
                    events.append(ScheduledClass(from: event))
                } else if event.checkDate(date: date) {
                    let newStartTime = adjustEventDate(event.eventStartDate!, targetDate: date)
                    let newEndTime = adjustEventDate(event.eventEndDate!, targetDate: date)

                    // I hate the ICS file format and this damn library I picked
                    var scheduledClass = ScheduledClass(from: event)
                    if let newStartTime {
                        scheduledClass.startDate = newStartTime
                    }
                    if let newEndTime {
                        scheduledClass.endDate = newEndTime
                    }

                    events.append(scheduledClass)
                }
            }

            Self.logger.info("Found \(events.count) class(es) for \(date)")

            return events.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        } else {
            try await initialiseCalendar()
            return try await getClasses(after: date)
        }
    }

    func adjustEventDate(_ eventDate: Date, targetDate: Date) -> Date? {
        let calendar = Calendar.current

        let targetComponents = calendar.dateComponents([.day, .month, .year], from: targetDate)

        guard
            let targetDay = targetComponents.day,
            let targetMonth = targetComponents.month,
            let targetYear = targetComponents.year
        else {
            Self.logger.error("Unable to extract date from target date")

            return nil
        }

        let originalTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: eventDate)

        guard
            let originalHour = originalTimeComponents.hour,
            let originalMinute = originalTimeComponents.minute,
            let originalSecond = originalTimeComponents.second
        else {
            Self.logger.error("Unable to extract time from event date")

            return nil
        }


        let adjustedDateComponents = DateComponents(
            year: targetYear,
            month: targetMonth,
            day: targetDay,

            hour: originalHour,
            minute: originalMinute,
            second: originalSecond
        )

        return calendar.date(from: adjustedDateComponents)
    }

    /// Returns a list of classes corresponding to the identifiers passed on based on each events iCalendar UID property.
    ///
    /// This method is intended to be used by the `TimetableIntents` framework only.
    ///
    /// >important: This method will automatically initialise the calendar used by the service if it has not already been initialised.
    /// - Parameter identifiers: A list of event identifiers to check for.
    /// - Returns: A list of classes that match the identifiers provided.
    public func getClasses(from identifiers: [ScheduledClass.ID]) async throws -> [ScheduledClass] {
        if let calendar {
            return calendar.events.filter({ identifiers.contains($0.eventUniqueID!) }).map { ScheduledClass(from: $0) }
        } else {
            try await initialiseCalendar()
            return try await getClasses(from: identifiers)
        }
    }

    private func cleanIcsString(_ string: String) -> String {
        var icsString = string

        // Windows Style line endings
        icsString = icsString.replacingOccurrences(of: "\r\n", with: "\n")
        // macOS Style line endings (pre OS X)
        icsString = icsString.replacingOccurrences(of: "\r", with: "\n")

        return icsString
    }

    /// A collection of errors that the service can generate.
    public enum Error: Swift.Error, CustomStringConvertible {
        /// Indicates that the service has no URL it can use to download the users timetable.
        ///
        /// This error is commonly thrown if the service has never been setup or if the cache file no longer exists and the timetable needs to be redownloaded.
        case noTimetableSpecified
        /// Indicates that the service cannot connect to the network to download the users timetable.
        case noNetworkAccess

        public var description: String {
            switch self {
                case .noTimetableSpecified:
                    "No remote URL was specified to retrieve the ics file from."
                case .noNetworkAccess:
                    "No network available to download .ics file."
            }
        }
    }
    
    /// Sets the URL that the service should use to download the users timetable.
    ///
    /// This does not need to be called after initialisation for the service to work as it will load the URL automatically.
    ///
    /// This should be called in the event the the user wishes to change the URL their timetable comes from or to tell the serice the URL when it is first being setup.
    ///
    /// >important: This will automatically call ``refresh()`` on the service.
    /// - Parameter url: URL of the remote timetable.
    public func setRemoteURL(_ url: URL?) {
        self.remoteIcsURL = url

        Task {
            try await refresh()
        }
    }
}

// MARK: Debug
extension TimetableService {
    /// Replaces the services in-memory calendar that events are loaded from with alternative valid iCalendar data.
    ///
    /// Intended for debug purposes only.
    ///
    /// >important: If ``refresh()`` is called and the remote URL is set the data provided will be overwritten.
    ///
    /// - Parameter icsData: iCalendar data to replace the in-memory calendar with.
    public func reinitialise(with icsData: Data) {
        let icsString = cleanIcsString(String(decoding: icsData, as: UTF8.self))

        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            calendar = try await MXLCalendarManager().parse(icsString: icsString)
        }

        semaphore.wait()
    }
    
    /// Erases the cached iCalendar file from disk if it exists.
    ///
    /// Intended for debug purposes only.
    public func clearCalendarCache() {
        if FileManager.default.fileExists(atPath: icsCacheURLPath) {
            do {
                try FileManager.default.removeItem(atPath: icsCacheURLPath)
                Self.logger.debug("Erased cached calendar.ics file")
            } catch {

            }
        }
    }
}

//MARK: Background Tasks
extension TimetableService {
    @discardableResult
    private func downloadRemoteTimetable() async throws -> Data {
        guard let remoteIcsURL else { throw TimetableService.Error.noTimetableSpecified }

        Self.logger.debug("Downloading remote calendar.ics file")
        if Task.isCancelled { return Data() }
        let icsData = try await URLSession.shared.data(from: remoteIcsURL)

        do {
            if !FileManager.default.fileExists(atPath: icsCacheURLPath) {
                FileManager.default.createFile(atPath: icsCacheURLPath, contents: icsData.0)
                assert(FileManager.default.fileExists(atPath: icsCacheURLPath))
            } else {
                try icsData.0.write(to: URL(filePath: icsCacheURLPath, directoryHint: .notDirectory), options: [.atomic])
            }
        } catch {
            Self.logger.error("\(error)")
        }

        Self.logger.debug("Wrote cached calendar.ics file to: \(self.icsCacheURLPath, privacy: .sensitive)")

        return icsData.0
    }

    private func loadCalendarDataFromCache() -> Data {
        assert(FileManager.default.fileExists(atPath: icsCacheURLPath))

        Self.logger.debug("Loading calendar.ics file from cache")

        return FileManager.default.contents(atPath: icsCacheURLPath)!
    }

    /// Schedules an app refresh task with the ``/BackgroundTasks/BGTaskScheduler``.
    ///
    /// This task is not handled by the service internally.
    /// It is expected that the app will call ``refresh()`` when the scheduler wakes the app to perform the task.
    @available(iOS 18, *)
    public func scheduleRefresh() {
        #if !os(macOS)
        // 4AM the next day which is when the remote timetable gets updated
        let taskStartDate: Date = .now.withoutTime.addingTimeInterval(86400).addingTimeInterval(60 * 60 * 4)
        let task = BGAppRefreshTaskRequest(identifier: "com.neo.My-Brighton.Timetable.refresh")
        task.earliestBeginDate = taskStartDate

        do {
            try BGTaskScheduler.shared.submit(task)
        } catch {
            Self.logger.error("Unable to schedule TimetableService refresh: \(error.localizedDescription)")
        }
        #endif
    }
    
    /// Refreshses the in-memory calendar and the cache file on disk.
    ///
    /// If this call does not fail it will also:
    /// - Schedule a refresh task with ``/BackgroundTasks/BGTaskScheduler``
    /// - Reload the Timetable widget of kind: `TimetableWidget`
    /// - Schedule notifications for today
    public func refresh() async throws {
        guard remoteIcsURL != nil else { throw TimetableService.Error.noTimetableSpecified }

        if let calendarDownloadTask {
            Self.logger.debug("Waiting for previous download task to complete before resuming \(#function)...")

            if case .failure(let error) = await calendarDownloadTask.result {
                Self.logger.warning("Previous download task failed with error: '\(error)'")
            }
        }

        calendarDownloadTask = Task {
            try await downloadRemoteTimetable()
            let icsData = loadCalendarDataFromCache()

            calendar = try! await MXLCalendarManager().parse(icsString: cleanIcsString(String(decoding: icsData, as: UTF8.self)))
        }

        // TODO: Find an alternative for macOS
        // Worth noting, if someone has opened the app on their Mac it should still display notifications when the app is closed
        // https://github.com/users/jds691/projects/11/views/3?pane=issue&itemId=129422657
#if !os(macOS)
        scheduleRefresh()
#endif

        if case .failure(let error) = await calendarDownloadTask!.result {
            throw error
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "TimelineWidget")
        // I'm assuming I'm calling this correctly
        await scheduleNotifications(for: .now)
    }
}

//MARK: Notifications
extension TimetableService {
    /// Schedules notifications to be send out for the users classes on the given date.
    ///
    /// If notifications have been previously scheduled for this date they will be automatically cancelled and rescheduled.
    /// - Parameter date: Date that the notifications are created for.
    public func scheduleNotifications(for date: Date) async {
        guard let notifier else { Self.logger.error("Notifier for service not initialised. Not schedueling notifications"); return }

        // TODO: Account for cancelled classes
        let classes: [ScheduledClass]

        do {
            classes = try await getClasses(after: date.withoutTime)
        } catch {
            Self.logger.error("\(error.localizedDescription)")
            return
        }

        await notifier.scheduleNotifications(for: classes.map { ScheduledClassInfo(from: $0) })

        /*do {
            if try await !UNUserNotificationCenter.current().requestAuthorization() { return }
        } catch {
            Self.logger.error("Failed to request authorisation for UNUserNotificationCenter")
            return
        }

        var requestIdentifiersToRemove: [String] = []

        let dateIdentifierFormatter = DateFormatter()
        dateIdentifierFormatter.dateFormat = "dd-MM-YYYY"

        let dateIdentifier = dateIdentifierFormatter.string(from: date.withoutTime)

        for notification in await UNUserNotificationCenter.current().pendingNotificationRequests().filter({ $0.identifier.starts(with: "timetable.") }) {
            if notification.identifier.starts(with: "timetable.\(dateIdentifier)") {
                requestIdentifiersToRemove.append(notification.identifier)
            }
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestIdentifiersToRemove)

        let classes: [ScheduledClass]

        do {
            classes = try await getClasses(after: date.withoutTime)
        } catch {
            Self.logger.error("\(error.localizedDescription)")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        for scheduledClass in classes {
            let content = UNMutableNotificationContent()
            content.title = scheduledClass.name
            content.body = "in \(scheduledClass.location) at \(formatter.string(from: scheduledClass.startDate))"
            content.sound = .default
            content.interruptionLevel = .timeSensitive
            content.categoryIdentifier = "Timetable"

            let requestTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: scheduledClass.startDate), repeats: false)
            let request = UNNotificationRequest(identifier: "timetable.\(dateIdentifier).\(scheduledClass.id)", content: content, trigger: requestTrigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                Self.logger.error("Failed to schedule notification for class '\(scheduledClass.id)': \(error.localizedDescription)")
            }
        }*/
    }
}
