//
//  Bundle++.swift
//  My Brighton
//
//  Created by Neo Salmon on 26/02/2026.
//

// Based off of the implementation in Signal-iOS

import Foundation

extension Bundle {
    private enum InfoPlistKey: String {
        case developmentTeamId = "DEV_TEAM_ID"
    }

    private func infoPlistString(for key: InfoPlistKey) -> String? {
        object(forInfoDictionaryKey: key.rawValue) as? String
    }

    /// Returns the value of the DEV\_TEAM\_ID from current executable's Info.plist
    public var developmentTeamId: String {
        if let prefix = infoPlistString(for: Self.InfoPlistKey.developmentTeamId) {
            return prefix
        } else {
            fatalError("Missing Info.plist entry for DEV_TEAM_ID")
        }
    }
}
