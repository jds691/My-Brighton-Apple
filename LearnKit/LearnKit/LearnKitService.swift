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
import AppIntents

/// Overarching service to perform requests against LearnKit.
///
/// All requests must be made through the service as it performs a lot of work in the backend for Spotlight and offline caching.
public final class LearnKitService: Sendable {
    private let baseURL: URL?
    private let client: any APIProtocol
    private let cache: BbCache
    private let displayRepresentationsLock: NSLock = NSLock()
    private let displayRepresentations: [any DisplayRepresentationProvider]

    private static let logger: Logger = .init(subsystem: "com.neo.LearnKit", category: "LearnKitService")

    /// Initialises the service with a Learn instance URL to connect to.
    ///
    /// - Parameter learnInstanceURL: The URL for the Blackboard Learn instance. The instance URL should end with "/learn/api/public".
    public init(learnInstanceURL: URL, displayRepresentations: [any DisplayRepresentationProvider] = []) {
        self.cache = BbCache()
        self.baseURL = learnInstanceURL
        self.client = Client(
            serverURL: learnInstanceURL,
            transport: URLSessionTransport()
        )
        self.displayRepresentations = displayRepresentations
    }

    
    /// Initialises the LearnKitService with a custom client.
    ///
    /// This initialiser is only intended to be used for previews.
    /// >important: Some API calls will not function with custom clients.
    /// - Parameter client: Custom client to use for REST calls.
    public init(client: any APIProtocol, displayRepresentations: [any DisplayRepresentationProvider] = []) {
        self.cache = BbCache(inMemoryOnly: true)
        self.baseURL = nil
        self.client = client
        self.displayRepresentations = displayRepresentations
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

    // MARK: (System) Announcements
    @discardableResult
    public func refreshSystemAnnouncements(for courseIdentifier: Course.ID) async throws -> [SystemAnnouncement] {
        let clientOutput = try await client.getV1Announcements()

        let results: Operations.GetV1Announcements.Output.Ok.Body.JsonPayload?

        switch clientOutput {
            case .ok(let netResults):
                results = try netResults.body.json
            case .forbidden(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .badRequest(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .undocumented(statusCode: let statusCode, _):
                throw LearnKitError.unknown(statusCode: statusCode)
        }

        guard let results else { throw LearnKitError.unknown(statusCode: nil) }
        let modelSystemAnnouncements = results.results.compactMap({ SystemAnnouncement(from: $0) })

        await cache.indexSystemAnnouncements(modelSystemAnnouncements)
        return modelSystemAnnouncements
    }

    public func getAllSystemAnnouncements() async throws -> [SystemAnnouncement] {
        return try await cache.getAllSystemAnnouncements()
    }

    public func getSystemAnnouncement(for identifier: SystemAnnouncement.ID) async throws -> SystemAnnouncement? {
        return try await cache.getSystemAnnouncement(for: identifier)
    }

    // MARK: Courses
    /// Refreshes the local cache of courses by communicating with the Learn instance and returns newer course data.
    /// - Returns: List of courses with newer content than what was previously cached.
    @discardableResult
    public func refreshCourses() async throws -> [Course] {
        // TODO: Keep track of the last time courses were fetched and add the modified param to the request
        let clientOutput = try await client.getV3Courses(.init())

        let results: Operations.GetV3Courses.Output.Ok.Body.JsonPayload?

        switch clientOutput {
            case .ok(let netResults):
                results = try netResults.body.json
            case .badRequest(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .undocumented(statusCode: let statusCode, let error):
                throw LearnKitError.unknown(statusCode: statusCode)
        }

        guard let results else { throw LearnKitError.unknown(statusCode: nil) }
        let modelCourses = results.results.compactMap({ Course(from: $0) })

        await cache.indexCourses(modelCourses)
        return modelCourses
    }

    public func getAllCourses() async throws -> [Course] {
        return try await cache.getAllCourses()
    }

    public func getCourse(for identifier: Course.ID) async throws -> Course? {
        return try await cache.getCourse(for: identifier)
    }

    // MARK: Course Announcements
    @discardableResult
    public func refreshCourseAnnouncements(for courseIdentifier: Course.ID) async throws -> [CourseAnnouncement] {
        let clientOutput = try await client.getV1CoursesCourseIdAnnouncements(.init(path: .init(courseId: courseIdentifier)))

        let results: Operations.GetV1CoursesCourseIdAnnouncements.Output.Ok.Body.JsonPayload?

        switch clientOutput {
            case .ok(let netResults):
                results = try netResults.body.json
            case .forbidden(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .badRequest(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .undocumented(statusCode: let statusCode, _):
                throw LearnKitError.unknown(statusCode: statusCode)
        }

        guard let results else { throw LearnKitError.unknown(statusCode: nil) }
        let modelCourseAnnouncements = results.results.compactMap({ CourseAnnouncement(from: $0) })

        await cache.indexCourseAnnouncements(modelCourseAnnouncements, for: courseIdentifier)
        return modelCourseAnnouncements
    }

    public func getAllCourseAnnouncements(for courseIdentifier: Course.ID) async throws -> [CourseAnnouncement] {
        return try await cache.getAllCourseAnnouncements(for: courseIdentifier)
    }

    public func getCourseAnnouncement(for identifier: CourseAnnouncement.ID, in course: Course.ID) async throws -> CourseAnnouncement? {
        return try await cache.getCourseAnnouncement(for: identifier, in: course)
    }

    // MARK: Content
    /// Refreshes the local cache version of the content for the given identifier.
    /// - Parameters:
    ///   - identifier: Identifier of the content to refresh.
    ///   - includeChildren: Indicates if the children of this content should also be refreshed. Default: true.
    ///   - courseIdentifier: Course that the content belongs to.
    /// - Returns: List of modified content items.
    @discardableResult
    public func refreshContent(for identifier: Content.ID, includeChildren: Bool = true, in courseIdentifier: Course.ID) async throws -> [Content] {
        let clientContentOutput = try await client.getV1CoursesCourseIdContentsContentId(.init(path: .init(courseId: courseIdentifier, contentId: identifier)))

        let foundContent = try clientContentOutput.ok.body.json

        let hasChildren = foundContent.hasChildren ?? true

        if !includeChildren || !hasChildren {
            if let content = Content(from: foundContent) {
                await cache.indexContent([content], for: courseIdentifier)
                return [content]
            } else {
                return []
            }
        }

        let clientChildrenOutput = try await client.getV1CoursesCourseIdContentsContentIdChildren(.init(path: .init(courseId: courseIdentifier, contentId: identifier)))

        let foundChildren: [Components.Schemas.Content]

        do {
            foundChildren = try clientChildrenOutput.ok.body.json.results
        } catch {
            throw LearnKitError.unknown(statusCode: nil)
        }

        let finalResults: [Content]
        if let content = Content(from: foundContent) {
            finalResults = [content] + foundChildren.compactMap { Content(from: $0) }
        } else {
            finalResults = foundChildren.compactMap { Content(from: $0) }
        }

        await cache.indexContent(finalResults, for: courseIdentifier)
        return finalResults
    }
    
    /// Refreshes the local cache version of the root content of the course for the given identifier.
    /// - Parameter courseIdentifier: Identifier of the course to refresh.
    /// - Returns: List of modified content items.
    @discardableResult
    public func refreshContentRoot(in courseIdentifier: Course.ID) async throws -> [Content] {
        // TODO: Keep track of the last time content was fetched and add the modified param to the request
        let clientOutput = try await client.getV1CoursesCourseIdContents(.init(path: .init(courseId: courseIdentifier)))

        let results: Operations.GetV1CoursesCourseIdContents.Output.Ok.Body.JsonPayload?

        switch clientOutput {
            case .ok(let netResults):
                results = try netResults.body.json
            case .badRequest(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .forbidden(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .undocumented(statusCode: let statusCode, _):
                throw LearnKitError.unknown(statusCode: statusCode)
        }

        guard let results else { throw LearnKitError.unknown(statusCode: nil) }
        let modelContent = results.results.compactMap({ Content(from: $0) })

        await cache.indexContent(modelContent, for: courseIdentifier)
        return modelContent
    }

    public func getChildContent(for identifier: Content.ID, in course: Course.ID) async throws -> [Content] {
        return try await cache.getChildContent(for: identifier, in: course)
    }

    public func getContent(for identifier: Content.ID, in course: Course.ID) async throws -> Content? {
        return try await cache.getContent(for: identifier, in: course)
    }

    public func getAllRootContent(in course: Course.ID) async throws -> [Content] {
        do {
            return try await cache.getAllRootContent(in: course)
        } catch {
            if let lkError = error as? LearnKitError, case .rootNodeMissing = lkError {
                try await refreshContent(for: "ROOT", includeChildren: false, in: course)

                return try await getAllRootContent(in: course)
            } else {
                throw error
            }
        }
    }

    // MARK: Terms
    /// Refreshes the local cache of terms by communicating with the Learn instance and returns newer term data.
    /// - Returns: List of terms with newer content than what was previously cached.
    @discardableResult
    public func refreshTerms() async throws -> [Term] {
        // TODO: Keep track of the last time terms were fetched and add the modified param to the request
        let clientOutput = try await client.getV1Terms(.init())

        let results: Operations.GetV1Terms.Output.Ok.Body.JsonPayload?

        switch clientOutput {
            case .ok(let netResults):
                results = try netResults.body.json
            case .forbidden(let error):
                throw try LearnKitError.restError(RestError(from: error.body.json))
            case .undocumented(statusCode: let statusCode, let error):
                throw LearnKitError.unknown(statusCode: statusCode)
        }

        guard let results else { throw LearnKitError.unknown(statusCode: nil) }
        let modelTerms = results.results.compactMap({ Term(from: $0) })

        await cache.indexTerms(modelTerms)
        return modelTerms
    }

    public func getAllTerms() async throws -> [Term] {
        return try await cache.getAllTerms()
    }

    public func getTerm(for identifier: Term.ID) async throws -> Term? {
        return try await cache.getTerm(for: identifier)
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

// MARK: DisplayRepresentationProvider
extension LearnKitService {
    func getDisplayRepresentationProvider<Entity: AppEntity>(for entity: Entity.Type) -> (any DisplayRepresentationProvider<Entity>)? {
        func extractProviderCategory<Provider: DisplayRepresentationProvider>(_ provider: Provider) -> any AppEntity.Type {
            return Provider.Entity.self
        }

        return displayRepresentations.first(where: { extractProviderCategory($0) == Entity.self }) as? any DisplayRepresentationProvider<Entity>
    }
}
