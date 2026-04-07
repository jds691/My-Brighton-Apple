//
//  Bundle++.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/02/2026.
//

import Foundation

extension Bundle {
    private enum InfoPlistKey: String {
        case studentNumber = "CUSTOM_STUDENT_NUMBER"
    }

    private func infoPlistString(for key: InfoPlistKey) -> String? {
        object(forInfoDictionaryKey: key.rawValue) as? String
    }

    /// Returns the value of the CUSTOM\_STUDENT\_NUMBER from current executable's Info.plist
    public var studentNumber: String {
        if let prefix = infoPlistString(for: Self.InfoPlistKey.studentNumber) {
            return prefix
        } else {
            fatalError("Missing Info.plist entry for CUSTOM_STUDENT_NUMBER")
        }
    }
}
