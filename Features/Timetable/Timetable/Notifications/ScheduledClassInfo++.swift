//
//  ScheduledClassInfo++.swift
//  Timetable
//
//  Created by Neo Salmon on 22/03/2026.
//

import Notifier

extension ScheduledClassInfo {
    init(from scheduledClass: ScheduledClass) {
        self.init(id: scheduledClass.id, name: scheduledClass.name, location: scheduledClass.location, startDate: scheduledClass.startDate)
    }
}
