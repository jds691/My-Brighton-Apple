//
//  PreviewAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 19/02/2026.
//

import Foundation

struct PreviewAnnouncement: Announcement {
    var id: String
    var title: String
    var body: String
    var creationDate: Date
    var lastModifiedDate: Date
    var position: Int
    var creatorId: String

    init(id: String, title: String, body: String, creationDate: Date, lastModifiedDate: Date, position: Int, creatorId: String) {
        self.id = id
        self.title = title
        self.body = body
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.position = position
        self.creatorId = creatorId
    }
}
