//
//  NotificationCategory.swift
//  Notifier
//
//  Created by Neo Salmon on 22/03/2026.
//

import Foundation
import UserNotifications

public enum NotificationCategory: RawRepresentable, CaseIterable {
    public init?(rawValue: String) {
        switch rawValue {
            case "MB.timetable.class-start":
                self = .timetabledClass
            default:
                return nil
        }
    }
    
    public var rawValue: String {
        switch self {
            case .timetabledClass:
                "MB.timetable.class-start"
        }
    }

    case timetabledClass
}

extension UNNotificationCategory {
    convenience init(for notifierCategory: NotificationCategory) {
        switch notifierCategory {
            case .timetabledClass:
                self.init(identifier: "MB.timetable.class-start", actions: [], intentIdentifiers: [])
        }
    }
}
