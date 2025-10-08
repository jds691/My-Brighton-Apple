//
//  TimetableRowView++.swift
//  My Brighton
//
//  Created by Neo Salmon on 16/09/2025.
//

import Timetable
import TimetableUI

extension TimetableRowView {
    init(_ entity: ScheduledClassEntity, prominent: Bool = false) {
        self.init(
            .init(
                id: entity.id,
                name: entity.name,
                location: entity.location,
                startDate: entity.startDate,
                endDate: entity.endDate,
                moduleCode: entity.moduleCode
            ),
            prominent: prominent
        )
    }
}
