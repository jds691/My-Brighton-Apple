//
//  UpdateState.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/03/2026.
//

import Foundation

public struct UpdateState: Codable {
    var sha1: String
    var patchNotes: String?
    var status: InstallationStatus
    var minRequiredXcodeVersion: String

    public enum InstallationStatus: String, Codable {
        case installed = "installed"
        case pending = "pending"
    }
}
