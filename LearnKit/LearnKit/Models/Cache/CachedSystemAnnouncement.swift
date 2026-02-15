//
//  CachedSystemAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 15/02/2026.
//

import Foundation
import SwiftData

@Model
class CachedSystemAnnouncement {
    var id: String
    var title: String
    var body: String
    var availability: CachedSystemAnnouncement.Availability
    var showAtLogin: Bool
    var showInCourses: Bool
    // TODO: Potentialy replace with a CachedCreator model at some point as a relationship
    var creatorID: String
    var creationDate: Date
    var lastModified: Date

    init(from systemAnnouncementModel: SystemAnnouncement) {
        self.id = systemAnnouncementModel.id
        self.title = systemAnnouncementModel.title
        self.body = systemAnnouncementModel.body
        self.availability = CachedSystemAnnouncement.Availability(from: systemAnnouncementModel.availability)
        self.showAtLogin = systemAnnouncementModel.showAtLogin
        self.showInCourses = systemAnnouncementModel.showInCourses
        self.creatorID = systemAnnouncementModel.creatorID
        self.creationDate = systemAnnouncementModel.creationDate
        self.lastModified = systemAnnouncementModel.lastModified
    }

    func copyValues(from systemAnnouncementModel: SystemAnnouncement) {
        self.id = systemAnnouncementModel.id
        self.title = systemAnnouncementModel.title
        self.body = systemAnnouncementModel.body
        self.availability = CachedSystemAnnouncement.Availability(from: systemAnnouncementModel.availability)
        self.showAtLogin = systemAnnouncementModel.showAtLogin
        self.showInCourses = systemAnnouncementModel.showInCourses
        self.creatorID = systemAnnouncementModel.creatorID
        self.creationDate = systemAnnouncementModel.creationDate
        self.lastModified = systemAnnouncementModel.lastModified
    }

    public enum Availability: Hashable, Sendable, Codable {
        case permenant
        case restricted(start: Date, end: Date)

        init(from systemAnnouncementAvailabilityModel: SystemAnnouncement.Availability) {
            switch systemAnnouncementAvailabilityModel {
                case .permenant:
                    self = .permenant
                case .restricted(let start, let end):
                    self = .restricted(start: start, end: end)
            }
        }
    }
}
