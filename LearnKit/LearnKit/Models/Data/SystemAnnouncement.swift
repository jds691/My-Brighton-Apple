//
//  SystemAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/10/2025.
//

import Foundation

public struct SystemAnnouncement: Hashable, Identifiable {
    public var id: String
    public var title: String
    public var body: String
    public var availability: Availability
    public var showAtLogin: Bool
    public var showInCourses: Bool
    public var creatorID: String
    public var creationDate: Date
    public var lastModified: Date

    init(apiSchema: Components.Schemas.SystemAnnouncement) {
        // TODO: Fix the OpenAPI docs
        self.id = apiSchema.id!
        self.title = apiSchema.title!
        self.body = apiSchema.body!
        self.availability = .permenant
        self.showAtLogin = apiSchema.showAtLogin!
        self.showInCourses = apiSchema.showInCourses!
        self.creatorID = apiSchema.creatorUserId!
        self.creationDate = apiSchema.created!
        self.lastModified = apiSchema.modified!
    }

    public enum Availability: Hashable {
        case permenant
        case duration(start: Date, end: Date)
    }
}
