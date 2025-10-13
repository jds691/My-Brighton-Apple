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

actor BbCache {
    private static let logger: Logger = Logger(subsystem: "com.neo.LearnKit", category: "BbCache")

    // TODO: Consider protection class
    private let searchableIndex: CSSearchableIndex = CSSearchableIndex(name: "LearnKit")

    private let modelExecutor: any ModelExecutor
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }

    init() {
        do {
            let schemaV1: Schema = .init([
                CachedCourse.self,
                CachedTerm.self
            ])
            let config: ModelConfiguration = .init(schema: schemaV1, groupContainer: .identifier("group.com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

    init(inMemoryOnly: Bool) {
        do {
            let schemaV1: Schema = .init([
                CachedCourse.self,
                CachedTerm.self
            ])
            let config: ModelConfiguration = .init(schema: schemaV1, isStoredInMemoryOnly: inMemoryOnly, groupContainer: .identifier("group.com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

    // MARK: Courses
    func indexCourses(_ courses: [Course]) async {
        for course in courses {
            do {
                let cachedCourse: CachedCourse? = try await getCourse(for: course.id)

                if let cachedCourse {
                    cachedCourse.copyValues(from: course)
                } else {
                    let newCachedCourse = CachedCourse(from: course)
                    newCachedCourse.term = try await getTerm(for: course.termId)
                    modelContext.insert(newCachedCourse)
                }
            } catch {
                Self.logger.error("Error while indexing course '\(course.id)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during course index: \(error)")
        }
    }

    // MARK: Terms
    func indexTerms(_ terms: [Term]) async {
        for term in terms {
            do {
                let cachedTerm: CachedTerm? = try await getTerm(for: term.id)

                if let cachedTerm {
                    cachedTerm.copyValues(from: term)
                } else {
                    let newCachedTerm = CachedTerm(from: term)
                    modelContext.insert(newCachedTerm)
                }
            } catch {
                Self.logger.error("Error while indexing term '\(term.id)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during term index: \(error)")
        }
    }
}

// MARK: LearnKitAPI
extension BbCache: LearnKitAPI {
    // MARK: Courses
    public func getAllCourses() async throws -> [Course] {
        return try modelContext.fetch(FetchDescriptor<CachedCourse>()).compactMap({ Course(from: $0) })
    }

    public func getCourse(for identifier: Course.ID) async throws -> Course? {
        var descriptor = FetchDescriptor<CachedCourse>(predicate: #Predicate<CachedCourse>{ $0.id == identifier })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstCourse = results.first, let course = Course(from: firstCourse) {
            return course
        } else {
            return nil
        }
    }

    func getCourse(for identifier: Course.ID) async throws -> CachedCourse? {
        var descriptor = FetchDescriptor<CachedCourse>(predicate: #Predicate<CachedCourse>{ $0.id == identifier })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstCourse = results.first {
            return firstCourse
        } else {
            return nil
        }
    }

    // MARK: Terms
    public func getAllTerms() async throws -> [Term] {
        return try modelContext.fetch(FetchDescriptor<CachedTerm>()).compactMap({ Term(from: $0) })
    }

    public func getTerm(for identifier: Term.ID) async throws -> Term? {
        var descriptor = FetchDescriptor<CachedTerm>(predicate: #Predicate<CachedTerm>{ $0.id == identifier })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstTerm = results.first {
            return Term(from: firstTerm)
        } else {
            return nil
        }
    }

    func getTerm(for identifier: Term.ID) async throws -> CachedTerm? {
        var descriptor = FetchDescriptor<CachedTerm>(predicate: #Predicate<CachedTerm>{ $0.id == identifier })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstTerm = results.first {
            return firstTerm
        } else {
            return nil
        }
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
