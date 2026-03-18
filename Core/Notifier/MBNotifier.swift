//
//  MBNotifier.swift
//  Notifier
//
//  Created by Neo Salmon on 18/03/2026.
//

import Foundation
import UserNotifications

public class MBNotifier: NSObject {
    public static let shared: MBNotifier = MBNotifier()

    private override init() {
        super.init()
    }
}

extension MBNotifier: UNUserNotificationCenterDelegate {

}
