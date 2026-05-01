//
//  AuthenticationError.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import Foundation

public enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case protectedCall

    public var errorDescription: String? {
        switch self {
            case .invalidCredentials:
                String(
                    localized: "AuthenticationError.invalidCredentials.errorDescription",
                    bundle: Bundle(for: AccountService.self)
                )
            case .protectedCall:
                String(
                    localized: "AuthenticationError.protectedCall.errorDescription",
                    bundle: Bundle(for: AccountService.self)
                )
        }
    }
}
