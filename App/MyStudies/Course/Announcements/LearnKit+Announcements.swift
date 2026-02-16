//
//  LearnKit+Announcements.swift
//  My Brighton
//
//  Created by Neo Salmon on 16/02/2026.
//

import Foundation
import LearnKit

protocol Announcement: Identifiable {
    var id: String { get }
    var title: String { get }
    var body: String { get }
    var creationDate: Date { get }
    var lastModifiedDate: Date { get }
    var position: Int { get }

    var creatorId: String { get }
}

extension SystemAnnouncement: Announcement {
    var lastModifiedDate: Date {
        lastModified
    }
    
    var position: Int {
        -1
    }
    
    var creatorId: String {
        creatorID
    }
}
