//
//  CachedCourseAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 18/02/2026.
//

import Foundation
import SwiftData

@Model
class CachedCourseAnnouncement {
    var id: CourseAnnouncement.ID
    var title: String
    var body: String
    var isDraft: Bool
    var availability: CachedCourseAnnouncement.Availability
    var creatorId: String
    var creationDate: Date
    var lastModifiedDate: Date
    var reachedUsersCount: Int?
    var positionIndex: Int
    var readCount: Int?

    // Relational fields
    var course: CachedCourse?

    init(from courseAnnouncementModel: CourseAnnouncement) {
        self.id = courseAnnouncementModel.id
        self.title = courseAnnouncementModel.title
        self.body = courseAnnouncementModel.body
        self.isDraft = courseAnnouncementModel.isDraft
        self.availability = Availability(from: courseAnnouncementModel.availability)
        self.creatorId = courseAnnouncementModel.creatorId
        self.creationDate = courseAnnouncementModel.creationDate
        self.lastModifiedDate = courseAnnouncementModel.lastModifiedDate
        self.reachedUsersCount = courseAnnouncementModel.reachedUsersCount
        self.positionIndex = courseAnnouncementModel.positionIndex
        self.readCount = courseAnnouncementModel.readCount
    }

    func copyValues(from courseAnnouncementModel: CourseAnnouncement) {
        self.id = courseAnnouncementModel.id
        self.title = courseAnnouncementModel.title
        self.body = courseAnnouncementModel.body
        self.isDraft = courseAnnouncementModel.isDraft
        self.availability = Availability(from: courseAnnouncementModel.availability)
        self.creatorId = courseAnnouncementModel.creatorId
        self.creationDate = courseAnnouncementModel.creationDate
        self.lastModifiedDate = courseAnnouncementModel.lastModifiedDate
        self.reachedUsersCount = courseAnnouncementModel.reachedUsersCount
        self.positionIndex = courseAnnouncementModel.positionIndex
        self.readCount = courseAnnouncementModel.readCount
    }

    enum Availability: Codable, Hashable, Sendable {
        case permanent
        case restricted(start: Date, end: Date)

        init(from courseAnnouncementAvailabilityModel: CourseAnnouncement.Availability) {
            switch courseAnnouncementAvailabilityModel {
                case .permanent:
                    self = .permanent
                case .restricted(let start, let end):
                    self = .restricted(start: start, end: end)
            }
        }
    }
}
