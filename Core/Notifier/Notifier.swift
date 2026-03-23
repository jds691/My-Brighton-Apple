//
//  Notifier.swift
//  Notifier
//
//  Created by Neo Salmon on 18/03/2026.
//

import os
import Foundation
import UserNotifications
import Router

@MainActor
public final class Notifier: NSObject, @MainActor UNUserNotificationCenterDelegate {
    private static let logger: Logger = Logger(subsystem: "com.neo.Notifier", category: "Notifier")
    private let router: Router

    public init(router: Router) {
        self.router = router

        UNUserNotificationCenter.current().setNotificationCategories(Set(NotificationCategory.allCases.map { UNNotificationCategory(for: $0) }))
    }

    @discardableResult
    public func requestAuthorisation() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert, .carPlay, .providesAppNotificationSettings])
        } catch {
            return false
        }
    }

    // MARK: Timetable
    public func scheduleNotifications(for classes: [ScheduledClassInfo]) async {
        let formatter = DateFormatter()
        formatter.dateFormat = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.formattingContext = .middleOfSentence
        relativeFormatter.dateTimeStyle = .numeric
        relativeFormatter.locale = Locale.current

        for scheduledClass in classes {
            let content = UNMutableNotificationContent()
            content.title = scheduledClass.name
            content.body = "in \(scheduledClass.location) at \(formatter.string(from: scheduledClass.startDate))"
            content.sound = .default
            content.interruptionLevel = .timeSensitive
            content.categoryIdentifier = NotificationCategory.timetabledClass.rawValue

            let earlyContent = content.mutableCopy() as! UNMutableNotificationContent
            earlyContent.title = "[Up Next] \(scheduledClass.name)"
            earlyContent.body = "at \(scheduledClass.location) \(relativeFormatter.localizedString(for: scheduledClass.startDate, relativeTo: scheduledClass.startDate.addingTimeInterval(-900)))"

            let earlyRequestTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: scheduledClass.startDate.addingTimeInterval(-900)), repeats: false)
            let earlyRequest = UNNotificationRequest(identifier: "timetable.\(scheduledClass.id).class-start.early", content: earlyContent, trigger: earlyRequestTrigger)

            do {
                try await UNUserNotificationCenter.current().add(earlyRequest)
            } catch {
                Self.logger.error("Failed to schedule early notification for class '\(scheduledClass.id)': \(error.localizedDescription)")
            }

            let requestTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: scheduledClass.startDate), repeats: false)
            let request = UNNotificationRequest(identifier: "timetable.\(scheduledClass.id).class-start", content: content, trigger: requestTrigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                Self.logger.error("Failed to schedule notification for class '\(scheduledClass.id)': \(error.localizedDescription)")
            }
        }
    }

    // MARK: UNUserNotificationCenterDelegate
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let category = NotificationCategory(rawValue: response.notification.request.content.categoryIdentifier) else { return }

        switch category {
            case .timetabledClass:
                router.navigate(to: .route(.home(.timetable(nil))))
        }
    }
}
