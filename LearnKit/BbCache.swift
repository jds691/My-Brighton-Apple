//
//  BbCache.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/08/2025.
//

import Foundation
import SwiftData
import os
import CoreSpotlight

//@ModelActor
actor BbCache {
    private static let logger: Logger = Logger(subsystem: "com.neo.My-Brighton.LearnKit", category: "BbCache")

    // TODO: Consider protection class
    private let searchableIndex: CSSearchableIndex = CSSearchableIndex(name: "LearnKit")

    init() {
        /*do {
            self.init(modelContainer: try .init(
                for:
                    CourseModel.self,
                    ContentModel.self,
                configurations: .init(isStoredInMemoryOnly: true)
            ))
        } catch {
            Self.logger.fault("Failed to initialise modelContainer for BbCache")
            fatalError()
        }*/
    }
}

// MARK: LearnKitAPI
extension BbCache: LearnKitAPI {
    // MARK: Courses
    func getAllCourses() {

    }

    func getCourse(for id: Course.ID) {

    }

    // MARK: Course Content
    func getAllContent(for id: Course.ID) {

    }

    func getContent(for contentId: Content.ID, from courseId: Course.ID) {

    }
}

// MARK: CoreSpotlight
extension BbCache {
    /// Reindexs all content stored in the cache back into CoreSpotlight.
    ///
    /// >important: Reindexing is only performed using the locally persisted cache. If there are remote changes not yet fetched they will not be reflected in newly indexed content.
    func reindexAllContent() async throws {
        //self.modelContainer.mainContext.fetch(T##descriptor: FetchDescriptor<PersistentModel>##FetchDescriptor<PersistentModel>)
    }

    /// Reindexes all content stored in the cache for the given identifiers back into CoreSpotlight.
    ///
    /// >important: Reindexing is only performed using the locally persisted cache. If there are remote changes not yet fetched they will not be reflected in newly indexed content.
    /// - Parameter identifiers: Identifiers of the content that should be reindexed.
    func reindexContent(withIdentifiers identifiers: [String]) async throws {

    }
}
