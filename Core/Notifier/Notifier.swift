//
//  Notifier.swift
//  Notifier
//
//  Created by Neo Salmon on 18/03/2026.
//

import Foundation
import UserNotifications
import Router

public final class Notifier: NSObject {
    private let router: Router

    public init(router: Router) {
        self.router = router
    }
}

extension Notifier: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {

    }
}
