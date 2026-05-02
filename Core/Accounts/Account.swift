//
//  Account.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import Foundation

public struct Account: Identifiable, Hashable, Sendable {
    public let id: UUID

    public let fullName: String
    public let studentNumber: String

    public let email: String

    public let remoteProfileUrl: URL?

    init() {
        self.id = UUID()
        self.fullName = ""
        self.studentNumber = ""
        self.email = ""
        self.remoteProfileUrl = nil
    }

    init(id: UUID, fullName: String, studentNumber: String, email: String, remoteProfileUrl: URL?) {
        self.id = id
        self.fullName = fullName
        self.studentNumber = studentNumber
        self.email = email
        self.remoteProfileUrl = remoteProfileUrl
    }

    static let exhibitionAccount = Account(
        id: UUID(),
        fullName: "DEMO",
        studentNumber: "27052026",
        email: "example@uni.brighton.ac.uk",
        remoteProfileUrl: nil
    )
}
