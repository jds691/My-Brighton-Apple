//
//  AuthenticationStatus.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import Foundation

@frozen
public enum AuthenticationStatus: Hashable, Sendable {
    case notAuthenticated
    case authenticationExpired
    case authenticated
}
