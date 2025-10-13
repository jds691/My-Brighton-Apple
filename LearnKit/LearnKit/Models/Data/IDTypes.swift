//
//  LearnID.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import Foundation

// MARK: Courses
/*public enum CourseID: Hashable, RawRepresentable {
    public init?(rawValue: String) {
        // TODO: Learn regex ig
        return nil
    }

    case primary(String) // AKA xid
    case external(String)
    case course(String)
    case uuid(UUID)

    public var rawValue: String {
        switch self {
            case .primary(let id):
                return id
            case .external(let id):
                return "externalId:\(id)"
            case .course(let id):
                return "courseId:\(id)"
            case .uuid(let id):
                return "uuid:\(id.uuidString.replacingOccurrences(of: "-", with: "").lowercased())"
        }
    }
}

public enum ContentID: Hashable, RawRepresentable {
    case primary(String)
    case keyword(Keyword)

    public enum Keyword: String {
        case interactive = "interactive"
        case indirect = "indirect"
        case root = "root"
    }

    public init?(rawValue: String) {
        // TODO: Learn Regex ig
        return nil
    }

    public var rawValue: String {
        switch self {
            case .primary(let string):
                return string
            case .keyword(let keyword):
                return keyword.rawValue
        }
    }
}
*/
