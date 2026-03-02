//
//  Navigation.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/10/2025.
//

import Foundation
import LearnKit

//https://talk.objc.io/episodes/S01E49-deep-linking
//https://github.com/kickstarter/ios-oss/blob/main/Library/Navigation.swift

public enum Navigation: Hashable {
    case route(_ route: Route)
    case modal(_ modal: Modal)

    public enum Route: Hashable, Identifiable {
        case home(Self.HomeSubRoute?)
        case myStudies(Self.MyStudiesSubRoute?)
        case bsu
        case search

        public var id: Self { self }

        // Refer to Obsidian for valid identifiers
        public init?(spotlightIdentifier: String) {
            let components = spotlightIdentifier.split(separator: "/")

            guard !components.isEmpty else { return nil }

            switch components[0] {
                case "course":
                    guard components.count >= 2 else { return nil }

                    self = Route.myStudies(.module(String(components[1]), nil))
                case "content":
                    guard components.count >= 3 else { return nil }

                    self = Route.myStudies(.module(String(components[1]), .content(String(components[2]))))
                default:
                    return nil
            }
        }

        public enum HomeSubRoute: Hashable, Identifiable {
            public var id: Self { self }

            case timetable(_ date: Date?)
        }

        public enum MyStudiesSubRoute: Hashable, Identifiable {
            public var id: Self { self }

            case module(Course.ID, Self.ModuleSubRoute?)

            public enum ModuleSubRoute: Hashable, Identifiable {
                public var id: Self { self }

                case announcements(CourseAnnouncement.ID?)
                case grades
                case dueDates
                case messages(String?) // Replace with Message.ID
                case discussions(String?) // Replace with Discussion.ID

                case content(Content.ID)
            }
        }
    }
}
