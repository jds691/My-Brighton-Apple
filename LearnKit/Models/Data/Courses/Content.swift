//
//  Content.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import SwiftBbML

public struct Content: Hashable, Identifiable {
    public private(set) var id: String

    //init(from remoteContent: Components.Schemas.Content)

    public enum State: String, Hashable {
        case none = "None" // Completely inaccessible
        case unlocked = "Unlocked" // Not read
        case started = "Started" // Partially read
        case completed = "Completed" // Fully read
    }
}
