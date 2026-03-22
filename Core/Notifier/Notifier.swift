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

public final class Notifier: NSObject {
    private static let logger: Logger = Logger(subsystem: "com.neo.Notifier", category: "Notifier")
    private let router: Router

    public init(router: Router) {
        self.router = router
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

        for scheduledClass in classes {
            let content = UNMutableNotificationContent()
            content.title = scheduledClass.name
            content.body = "in \(scheduledClass.location) at \(formatter.string(from: scheduledClass.startDate))"
            content.sound = .default
            content.interruptionLevel = .timeSensitive
            content.categoryIdentifier = NotificationCategory.timetabledClass.rawValue

            let requestTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: scheduledClass.startDate), repeats: false)
            let request = UNNotificationRequest(identifier: "timetable.\(scheduledClass.id).class-start", content: content, trigger: requestTrigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                Self.logger.error("Failed to schedule notification for class '\(scheduledClass.id)': \(error.localizedDescription)")
            }
        }
    }
}

// MARK: UNUserNotificationCenterDelegate
extension Notifier: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let category = NotificationCategory(rawValue: response.notification.request.content.categoryIdentifier) else { return }

        switch category {
            case .timetabledClass:
                await router.navigate(to: .route(.home(.timetable(nil))))
        }
    }
}
