//
//  CourseAnnouncementIDUnion.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/02/2026.
//

import Foundation
import LearnKit

nonisolated
public struct CourseAnnouncementIDUnion: Hashable, Codable, Sendable {
    public let courseId: Course.ID
    public let announcementId: CourseAnnouncement.ID

    public init(courseId: Course.ID, announcementId: CourseAnnouncement.ID) {
        self.courseId = courseId
        self.announcementId = announcementId
    }
}
