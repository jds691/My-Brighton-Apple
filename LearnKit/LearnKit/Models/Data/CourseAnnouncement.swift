//
//  CourseAnnouncement.swift
//  My Brighton
//
//  Created by Neo Salmon on 16/02/2026.
//

import Foundation
import os

public struct CourseAnnouncement: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "CourseAnnouncement")

    public let id: String
    public let title: String
    public let body: String
    public let isDraft: Bool
    public let creatorId: String
    public let creationDate: Date
    public let lastModifiedDate: Date
    public let reachedUsersCount: Int?
    public let positionIndex: Int
    public let readCount: Int?

    public enum Availability: Hashable, Sendable {
        case permanent
        case restricted(start: Date, end: Date)
    }
}
