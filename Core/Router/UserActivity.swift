//
//  UserActivity.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/09/2025.
//

public enum UserActivity {
    public enum Timetable {
        public static let view: String = "com.neo.My-Brighton.timetable.view"
    }

    public enum MyStudies {
        public enum Content {
            public static let view: String = "com.neo.My-Brighton.my-studies.content.view"
        }

        public enum Course {
            public enum Announcement {
                public static let view: String = "com.neo.My-Brighton.my-studies.course.announcement.view"
            }
        }
    }
}
