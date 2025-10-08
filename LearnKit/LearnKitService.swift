//
//  LearnKitService.swift
//  My Brighton
//
//  Created by Neo Salmon on 12/08/2025.
//

import Foundation
import OpenAPIURLSession
import SwiftUI
import AuthenticationServices
import os

public final class LearnKitService: Sendable {
    private let baseURL: URL?
    private let client: any APIProtocol
    private let cache: BbCache

    private static let logger: Logger = .init(subsystem: "com.neo.My-Brighton.LearnKit", category: "LearnKitService")

    ///
    ///
    /// - Parameter learnInstanceURL: The URL for the Blackboard Learn instance. The instance URL should end with "/learn/api/public".
    public init(learnInstanceURL: URL) {
        self.cache = BbCache()
        self.baseURL = learnInstanceURL
        self.client = Client(
            serverURL: learnInstanceURL,
            transport: URLSessionTransport()
        )
    }

    
    /// Initialises the LearnKitService with a custom client.
    ///
    /// This initialiser is only intended to be used for previews.
    /// >important: Some API calls will not function with custom clients.
    /// - Parameter client: Custom client to use for REST calls.
    public init(client: any APIProtocol) {
        self.cache = BbCache()
        self.baseURL = nil
        self.client = client
    }
}

// MARK: LearnKitAPI
extension LearnKitService: LearnKitAPI {
    @discardableResult
    public func authenticateUser(using session: WebAuthenticationSession) async throws -> Bool {
        // TODO: Check last known token and if it is refreshable, cancel this task and just refresh the token

        guard let baseURL else {
            Self.logger.error("`\(#function)` cannot be called from a custom client.")
            return false
        }

        let authPathComponents = Operations.GetV1Oauth2Authorizationcode.id.dropFirst(4) // drops the prepended "get/"
        let authURL = baseURL
            .appending(path: authPathComponents, directoryHint: .notDirectory)
            .appending(queryItems: [
                .init(name: "redirect_uri", value: "mybrighton://auth"),
                .init(name: "response_type", value: "code"),
                .init(name: "client_id", value: nil),
                .init(name: "scope", value: "read write delete offline"),
                .init(name: "state", value: UUID().uuidString)
            ])

        let callbackURL: URL = try await session.authenticate(
            using: authURL,
            callback: .customScheme("mybrighton"),
            additionalHeaderFields: [
                "Content-Type": "form/urlencoded"
            ]
        )

        return true
    }
}

// MARK: Spotlight Indexing
public extension LearnKitService {
    /// Reindexs all content managed by the LearnKitService back into CoreSpotlight.
    ///
    /// >important: Reindexing is only performed using the locally persisted cache. If there are remote changes not yet fetched they will not be reflected in newly indexed content.
    func reindexAllContent() async throws {
        try await cache.reindexAllContent()
    }

    /// Reindexes all content managed by the LearnKitService for the given identifiers back into CoreSpotlight.
    ///
    /// >important: Reindexing is only performed using the locally persisted cache. If there are remote changes not yet fetched they will not be reflected in newly indexed content.
    /// - Parameter identifiers: Identifiers of the content that should be reindexed.
    func reindexContent(withIdentifiers identifiers: [String]) async throws {
        try await cache.reindexContent(withIdentifiers: identifiers)
    }
}
