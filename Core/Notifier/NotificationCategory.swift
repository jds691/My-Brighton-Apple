//
//  NotificationCategory.swift
//  Notifier
//
//  Created by Neo Salmon on 22/03/2026.
//

import Foundation

public enum NotificationCategory: RawRepresentable {
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
