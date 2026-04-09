//
//  CourseDisplayRepresentationProvider.swift
//  My Brighton
//
//  Created by Neo Salmon on 09/04/2026.
//

import AppIntents
import LearnKit

struct CourseDisplayRepresentationProvider: DisplayRepresentationProvider<CourseEntity> {
    func representation(for entity: CourseEntity) -> DisplayRepresentation? {
        DisplayRepresentation(title: "FUCK", image: .init(systemName: "xmark", isTemplate: true))
    }
}
