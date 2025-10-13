//
//  LearnKitError.swift
//  My Brighton
//
//  Created by Neo Salmon on 12/10/2025.
//

public enum LearnKitError: Error {
    case restError(_ error: RestError)
    case unknown(statusCode: Int?)
}
