//
//  CourseAnnouncementIDUnion.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/02/2026.
//

import Foundation
import LearnKit

nonisolated
struct CourseAnnouncementIDUnion: Hashable, Codable, Sendable {
    var courseId: Course.ID
    var announcementId: CourseAnnouncement.ID
}
