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
import AppIntents
import SwiftBbML
import CustomisationKit

/// Handles all SwiftData and offline caching operations.
///
/// BbCache manages all offline operations for Learn API REST information. It will:
/// - Indexes information received from the API into SwiftData
/// - Indexes SwiftData information into CoreSpotlight
actor BbCache {
    private static let logger: Logger = Logger(subsystem: "com.neo.LearnKit", category: "BbCache")

    // TODO: Consider protection class
    private let searchableIndex: CSSearchableIndex = CSSearchableIndex(name: "LearnKit")

    private let modelExecutor: any ModelExecutor
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }
    
    /// Initialises the cache database with the current schema version.
    init() {
        do {
            let schemaV1: Schema = .init([
                CachedCourse.self,
                CachedContent.self,
                CachedTerm.self,
                CachedSystemAnnouncement.self,
                CachedCourseAnnouncement.self,
                CachedGradeColumn.self,
                CachedGradebookAttempt.self
            ])
            let config: ModelConfiguration = .init("BbCache", schema: schemaV1, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }
    
    /// Initialises a version of the cache database designed for testing and previews.
    /// - Parameter inMemoryOnly: Indicates if the database is in-memory only, useful for initialising many instances in test suites,
    init(inMemoryOnly: Bool) {
        do {
            let schemaV1: Schema = .init([
                CachedCourse.self,
                CachedContent.self,
                CachedTerm.self,
                CachedSystemAnnouncement.self,
                CachedCourseAnnouncement.self,
                CachedGradeColumn.self,
                CachedGradebookAttempt.self
            ])
            let config: ModelConfiguration = .init("BbCache", schema: schemaV1, isStoredInMemoryOnly: inMemoryOnly, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

    // MARK: (System) Announcements
    func indexSystemAnnouncements(_ announcements: [SystemAnnouncement]) async {
        for announcement in announcements {
            do {
                let cachedSAnnouncement: CachedSystemAnnouncement? = try await getSystemAnnouncement(for: announcement.id)

                if let cachedSAnnouncement {
                    cachedSAnnouncement.copyValues(from: announcement)
                } else {
                    let newCachedSAnnouncement = CachedSystemAnnouncement(from: announcement)
                    modelContext.insert(newCachedSAnnouncement)
                }
            } catch {
                Self.logger.error("Error while indexing system announcement '\(announcement.id)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during system announcement index: \(error)")
        }
    }

    // MARK: Courses
    /// Indexes the provided courses into SwiftData and CoreSpotlight.
    /// - Parameter courses: Courses to index.
    func indexCourses(_ courses: [Course]) async {
        async let courseIndexing: () = indexCoursesIntoSpotlight(courses)

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

        await courseIndexing
    }

    private func indexCoursesIntoSpotlight(_ courses: [Course]) async {
        var csItems: [CSSearchableItem] = []
        for course in courses {
            async let courseAppEntity = CourseEntity(from: course)
            let courseAttributes = CSSearchableItemAttributeSet()

            let customisations = CustomisationService.shared.getCourseCustomisation(for: course.id)

            courseAttributes.title = course.name
            courseAttributes.displayName = customisations.displayNameOverride ?? course.name
            courseAttributes.contentDescription = course.description
            courseAttributes.alternateNames = [
                course.id,
                course.courseId,
                course.externalAccessUrl.absoluteString
            ]
            courseAttributes.keywords = [
                "course",
                "module",
                "My Studies",
                course.courseId
            ]
            courseAttributes.metadataModificationDate = course.lastModified
            courseAttributes.thumbnailURL = CustomisationService.shared.thumbnailUrl(for: course.id, nilIfNonExistent: true)

            let courseCsItem = CSSearchableItem(uniqueIdentifier: "course/\(course.id)", domainIdentifier: nil, attributeSet: courseAttributes)
            await courseCsItem.associateAppEntity(courseAppEntity)

            csItems.append(courseCsItem)
        }

        do {
            try await searchableIndex.indexSearchableItems(csItems)
        } catch {
            Self.logger.error("Spotlight indexing error for courses: \(error)")
        }
    }

    // MARK: Course Announcements
    func indexCourseAnnouncements(_ announcements: [CourseAnnouncement], for courseIdentifier: Course.ID) async {
        async let announcementIndexing: () = indexCourseAnnouncementsIntoSpotlight(announcements, for: courseIdentifier)

        for announcement in announcements {
            do {
                let cachedCAnnouncement: CachedCourseAnnouncement? = try await getCourseAnnouncement(for: announcement.id, in: courseIdentifier)

                if let cachedCAnnouncement {
                    cachedCAnnouncement.copyValues(from: announcement)
                } else {
                    let newCachedCAnnouncement = CachedCourseAnnouncement(from: announcement)
                    newCachedCAnnouncement.course = try await getCourse(for: courseIdentifier)
                    modelContext.insert(newCachedCAnnouncement)
                }
            } catch {
                Self.logger.error("Error while indexing course announcement '\(announcement.id)' in course '\(courseIdentifier)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during course announcement index: \(error)")
        }

        await announcementIndexing
    }

    private func indexCourseAnnouncementsIntoSpotlight(_ announcements: [CourseAnnouncement], for courseIdentifier: Course.ID) async {
        var csItems: [CSSearchableItem] = []
        for announcement in announcements {
            let cAnnouncementAttributes = CSSearchableItemAttributeSet()

            cAnnouncementAttributes.title = announcement.title
            cAnnouncementAttributes.displayName = announcement.title
            cAnnouncementAttributes.contentDescription = returnBbMLText(announcement.body)
            cAnnouncementAttributes.alternateNames = [
                announcement.id,
            ]
            cAnnouncementAttributes.keywords = [
                "announcement",
                "My Studies",
                announcement.id
            ]
            cAnnouncementAttributes.metadataModificationDate = announcement.lastModifiedDate
            let cAnnouncementCsItem = CSSearchableItem(uniqueIdentifier: "announcement/\(courseIdentifier)/\(announcement.id)", domainIdentifier: nil, attributeSet: cAnnouncementAttributes)
            if case .restricted(start: _, end: let end) = announcement.availability {
                cAnnouncementCsItem.expirationDate = end
            }

            csItems.append(cAnnouncementCsItem)
        }

        do {
            try await searchableIndex.indexSearchableItems(csItems)
        } catch {
            Self.logger.error("Spotlight indexing error for course announcements: \(error)")
        }
    }

    // MARK: Course Grades
    func indexGradeColumns(_ columns: [GradeColumn], for courseIdentifier: Course.ID) async {
        for column in columns {
            do {
                let cachedCourse: CachedCourse? = try await getCourse(for: courseIdentifier)
                let associatedContent: CachedContent? = column.contentId != nil ? try await getContent(for: column.contentId!, in: courseIdentifier) : nil
                let cachedGradeColumn: CachedGradeColumn? = try await getGradeColumn(for: column.id, in: courseIdentifier)

#if DEBUG
                assert(cachedCourse != nil)
                if column.contentId != nil {
                    assert(associatedContent != nil)
                }
#endif

                if let existingCachedGradeColumn = cachedGradeColumn {
                    existingCachedGradeColumn.copyValues(from: column)
                    existingCachedGradeColumn.course = cachedCourse

                    if let existingAssociatedContent = associatedContent {
                        existingCachedGradeColumn.relatedContent = existingAssociatedContent
                    }
                } else {
                    let newCachedGradeColumn = CachedGradeColumn(from: column)
                    newCachedGradeColumn.course = cachedCourse

                    if let existingAssociatedContent = associatedContent {
                        newCachedGradeColumn.relatedContent = existingAssociatedContent
                    }

                    modelContext.insert(newCachedGradeColumn)
                }
            } catch {
                Self.logger.error("Error while indexing grade column '\(column.id)' in course '\(courseIdentifier)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during grade column index: \(error)")
        }
    }

    func indexGradebookAttempts(_ attempts: [GradebookAttempt], for columnIdentifier: GradeColumn.ID, in courseIdentifier: Course.ID) async {
        for attempt in attempts {
            do {
                let associatedGradeColumn: CachedGradeColumn? = try await getGradeColumn(for: columnIdentifier, in: courseIdentifier)
                let cachedGradebookAttempt: CachedGradebookAttempt? = try await getGradebookAttempt(by: attempt.id, for: columnIdentifier, in: courseIdentifier)

#if DEBUG
                assert(associatedGradeColumn != nil)
#endif

                if let existingCachedGradebookAttempt = cachedGradebookAttempt {
                    existingCachedGradebookAttempt.copyValues(from: attempt)
                    existingCachedGradebookAttempt.associatedGradeColumn = associatedGradeColumn
                } else {
                    let newCachedGradebookAttempt = CachedGradebookAttempt(from: attempt)
                    newCachedGradebookAttempt.associatedGradeColumn = associatedGradeColumn

                    modelContext.insert(newCachedGradebookAttempt)
                }
            } catch {
                Self.logger.error("Error while indexing gradebook attempt '\(attempt.id)' for grade column '\(columnIdentifier)' in course '\(courseIdentifier)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during grade column index: \(error)")
        }
    }

    // MARK: Content
    func indexContent(_ content: [Content], for courseIdentifier: Course.ID) async {
        for item in content {
            do {
                let cachedCourse: CachedCourse? = try await getCourse(for: courseIdentifier)
                let parentContent: CachedContent? = item.parentId != nil ? try await getContent(for: item.parentId!, in: courseIdentifier) : nil
                let cachedContent: CachedContent? = try await getContent(for: item.id, in: courseIdentifier)

#if DEBUG
                assert(cachedCourse != nil)
                if item.parentId != nil {
                    assert(parentContent != nil)
                }
#endif

                if let existingCachedContent = cachedContent {
                    existingCachedContent.copyValues(from: item)
                    existingCachedContent.course = cachedCourse

                    if let existingParentContent = parentContent {
                        existingCachedContent.parent = existingParentContent
                    }
                } else {
                    let newCachedContent = CachedContent(from: item)
                    newCachedContent.course = cachedCourse

                    if let existingParentContent = parentContent {
                        newCachedContent.parent = existingParentContent
                    }

                    modelContext.insert(newCachedContent)
                }
            } catch {
                Self.logger.error("Error while indexing content '\(item.id)': \(error)")
            }
        }

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error while saving modelContext during content index: \(error)")
        }
    }

    // MARK: Terms
    /// Indexes the provided terms into SwiftData and CoreSpotlight.
    /// - Parameter courses: Terms to index.
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
    // MARK: (System) Announcements
    func getAllSystemAnnouncements() async throws -> [SystemAnnouncement] {
        return try modelContext.fetch(FetchDescriptor<CachedSystemAnnouncement>()).compactMap({ SystemAnnouncement(from: $0) })
    }

    func getSystemAnnouncement(for identifier: SystemAnnouncement.ID) async throws -> SystemAnnouncement? {
        if let cachedSAnnouncement: CachedSystemAnnouncement = try await getSystemAnnouncement(for: identifier) {
            return SystemAnnouncement(from: cachedSAnnouncement)
        } else {
            return nil
        }
    }

    func getSystemAnnouncement(for identifier: SystemAnnouncement.ID) async throws -> CachedSystemAnnouncement? {
        var descriptor = FetchDescriptor<CachedSystemAnnouncement>(predicate: #Predicate<CachedSystemAnnouncement>{ $0.id == identifier })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstSAnnouncement = results.first {
            return firstSAnnouncement
        } else {
            return nil
        }
    }

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

    // MARK: Course Announcements
    func getAllCourseAnnouncements(for courseIdentifier: Course.ID) async throws -> [CourseAnnouncement] {
        return try modelContext.fetch(FetchDescriptor<CachedCourseAnnouncement>(predicate: #Predicate<CachedCourseAnnouncement>{ $0.course?.id == courseIdentifier })).compactMap({ CourseAnnouncement(from: $0) })
    }

    func getCourseAnnouncement(for identifier: CourseAnnouncement.ID, in course: Course.ID) async throws -> CourseAnnouncement? {
        if let cachedCAnnouncement: CachedCourseAnnouncement = try await getCourseAnnouncement(for: identifier, in: course) {
            return CourseAnnouncement(from: cachedCAnnouncement)
        } else {
            return nil
        }
    }

    func getCourseAnnouncement(for identifier: CourseAnnouncement.ID, in course: Course.ID) async throws -> CachedCourseAnnouncement? {
        var descriptor = FetchDescriptor<CachedCourseAnnouncement>(predicate: #Predicate<CachedCourseAnnouncement>{ $0.id == identifier && $0.course?.id == course })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstCAnnouncement = results.first {
            return firstCAnnouncement
        } else {
            return nil
        }
    }

    // MARK: Course Grades
    func getAllGradeColumns(for courseIdentifier: Course.ID) async throws -> [CachedGradeColumn] {
        var descriptor = FetchDescriptor<CachedCourse>(predicate: #Predicate<CachedCourse>{ $0.id == courseIdentifier })
        descriptor.fetchLimit = 1

        guard let course = try modelContext.fetch(descriptor).first else {
            Self.logger.warning("Unable to find CachedCourse for id '\(courseIdentifier)' when calling `\(#function)`")
            return []
        }

        return course.gradeColumns
    }

    func getGradeColumn(for identifier: GradeColumn.ID, in course: Course.ID) async throws -> CachedGradeColumn? {
        var descriptor = FetchDescriptor<CachedGradeColumn>(predicate: #Predicate<CachedGradeColumn>{ $0.id == identifier && $0.course?.id == course })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstGradeColumn = results.first {
            return firstGradeColumn
        } else {
            return nil
        }
    }

    func getAllGradeColumns(for courseIdentifier: Course.ID) async throws -> [GradeColumn] {
        return try await getAllGradeColumns(for: courseIdentifier).map { GradeColumn(from: $0) }
    }

    func getGradeColumn(for identifier: GradeColumn.ID, in course: Course.ID) async throws -> GradeColumn? {
        if let cachedGradeColumn: CachedGradeColumn = try await getGradeColumn(for: identifier, in: course) {
            return GradeColumn(from: cachedGradeColumn)
        } else {
            return nil
        }
    }

    func getGradebookAttempts(for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> [CachedGradebookAttempt] {
        var descriptor = FetchDescriptor<CachedGradeColumn>(predicate: #Predicate<CachedGradeColumn>{ $0.id == columnIdentifier && $0.course?.id == course })
        descriptor.fetchLimit = 1

        guard let gradeColumn = try modelContext.fetch(descriptor).first else {
            Self.logger.warning("Unable to find CachedGradeColumn for id '\(columnIdentifier)' in course '\(course)' when calling `\(#function)`")
            return []
        }

        return gradeColumn.attempts
    }

    func getGradebookAttempt(by attemptId: GradebookAttempt.ID, for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> CachedGradebookAttempt? {
        var descriptor = FetchDescriptor<CachedGradebookAttempt>(predicate: #Predicate<CachedGradebookAttempt>{ $0.id == attemptId && $0.associatedGradeColumn?.id == columnIdentifier && $0.associatedGradeColumn?.course?.id == course })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstGradebookAttempt = results.first {
            return firstGradebookAttempt
        } else {
            return nil
        }
    }

    func getLastGradebookAttempt(for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> CachedGradebookAttempt? {
        // TODO: Double check this
        var descriptor = FetchDescriptor<CachedGradebookAttempt>(
            predicate: #Predicate<CachedGradebookAttempt>{ $0.associatedGradeColumn?.id == columnIdentifier && $0.associatedGradeColumn?.course?.id == course },
            sortBy: [SortDescriptor(\.created, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstGradebookAttempt = results.first {
            return firstGradebookAttempt
        } else {
            return nil
        }
    }

    func getGradebookAttempts(for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> [GradebookAttempt] {
        return try await getGradebookAttempts(for: columnIdentifier, in: course).map { GradebookAttempt(from: $0) }
    }

    func getGradebookAttempt(by attemptId: GradebookAttempt.ID, for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> GradebookAttempt? {
        if let cachedGradebookAttempt: CachedGradebookAttempt = try await getGradebookAttempt(by: attemptId, for: columnIdentifier, in: course) {
            return GradebookAttempt(from: cachedGradebookAttempt)
        } else {
            return nil
        }
    }

    func getLastGradebookAttempt(for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> GradebookAttempt? {
        if let cachedGradebookAttempt: CachedGradebookAttempt = try await getLastGradebookAttempt(for: columnIdentifier, in: course) {
            return GradebookAttempt(from: cachedGradebookAttempt)
        } else {
            return nil
        }
    }

    // MARK: Content
    func getSpecialContentNode(for identifier: String, in course: Course.ID) async throws -> Content? {
        switch identifier {
            case "ROOT":
                return try await getRootNode(for: course)
            default:
                return nil
        }
    }

    func getRootNode(for courseIdentifier: Course.ID) async throws -> Content? {
        var descriptor = FetchDescriptor<CachedContent>(predicate: #Predicate<CachedContent>{ $0.parent == nil && $0.course?.id == courseIdentifier })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstContent = results.first, let content = Content(from: firstContent) {
            return content
        } else {
            return nil
        }
    }

    public func getAllRootContent(in course: Course.ID) async throws -> [Content] {
        guard let rootNode = try await getRootNode(for: course) else { throw LearnKitError.rootNodeMissing }
        // I have no idea why this was needed, but it is
        let nodeId: String = rootNode.id

        let predicate = #Predicate<CachedContent>{ $0.parent?.id == nodeId && $0.course?.id == course }
        let descriptor = FetchDescriptor<CachedContent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.positionIndex)]
        )

        return try modelContext.fetch(descriptor).compactMap({ Content(from: $0) })
    }

    public func getChildContent(for identifier: Content.ID, in course: Course.ID) async throws -> [Content] {
        let parentIdentifier: Content.ID

        if let specialContent = try await getSpecialContentNode(for: identifier, in: course) {
            parentIdentifier = specialContent.id
        } else {
            parentIdentifier = identifier
        }

        let predicate = #Predicate<CachedContent>{ $0.parent?.id == parentIdentifier && $0.course?.id == course }
        let descriptor = FetchDescriptor<CachedContent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.positionIndex)]
        )

        return try modelContext.fetch(descriptor).compactMap({ Content(from: $0) })
    }

    public func getContent(for identifier: Content.ID, in course: Course.ID) async throws -> Content? {
        if let specialContent = try await getSpecialContentNode(for: identifier, in: course) {
            return specialContent
        }

        var descriptor = FetchDescriptor<CachedContent>(predicate: #Predicate<CachedContent>{ $0.id == identifier && $0.course?.id == course })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstContent = results.first, let content = Content(from: firstContent) {
            return content
        } else {
            return nil
        }
    }

    func getContent(for identifier: Content.ID, in course: Course.ID) async throws -> CachedContent? {
        if let specialContent = try await getSpecialContentNode(for: identifier, in: course) {
            return CachedContent(from: specialContent)
        }

        var descriptor = FetchDescriptor<CachedContent>(predicate: #Predicate<CachedContent>{ $0.id == identifier && $0.course?.id == course })
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let firstContent = results.first {
            return firstContent
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

    // MARK: BbML Formatting
    private func returnBbMLText(_ bbMLString: String) -> String? {
        guard let content = try? BbMLParser().parse(bbMLString) else {
            return nil
        }

        let textChunks = content.filter({
            if case .text(_) = $0 {
                return true
            } else {
                return false
            }
        })

        var attrString = AttributedString()
        for textChunk in textChunks {
            if !attrString.characters.isEmpty {
                attrString.append(AttributedString("\n"))
            }

            guard case .text(let chunkText) = textChunk else {
                return nil
            }

            attrString.append(chunkText)
        }

        return String(attrString.characters)
    }
}

// MARK: CoreSpotlight
extension BbCache {
    /// Reindexs all content stored in the cache back into CoreSpotlight.
    ///
    /// >important: Reindexing is only performed using the locally persisted cache. If there are remote changes not yet fetched they will not be reflected in newly indexed content.
    func reindexAllContent() async throws {
        let coursesFetchDescriptor = FetchDescriptor<CachedCourse>()

        let courses = try modelContext.fetch(coursesFetchDescriptor).compactMap({ Course(from: $0) })
        async let courseIndexing: () = indexCoursesIntoSpotlight(courses)

        await courseIndexing
    }

    /// Reindexes all content stored in the cache for the given identifiers back into CoreSpotlight.
    ///
    /// >important: Reindexing is only performed using the locally persisted cache. If there are remote changes not yet fetched they will not be reflected in newly indexed content.
    /// - Parameter identifiers: Identifiers of the content that should be reindexed.
    func reindexContent(withIdentifiers identifiers: [String]) async throws {
        let spotlightItems: [SpotlightContentType] = identifiers.compactMap({ SpotlightContentType(from: $0) })

        let courseItems = spotlightItems.filter({
            if case .course(_) = $0 {
                return true
            } else {
                return false
            }
        })
        let cAnnouncementItems = spotlightItems.filter({
            if case .courseAnnouncement(id: _, courseId: _) = $0 {
                return true
            } else {
                return false
            }
        })

        async let courseIndexing: () = reindexCourseItems(courseItems)
        async let cAnnouncementIndexing: () = reindexCAnnouncementItems(cAnnouncementItems)

        try await courseIndexing
        try await cAnnouncementIndexing
    }

    func reindexCourseItems(_ identifiers: [SpotlightContentType]) async throws {
        let courseIdentifiers: [Course.ID] = identifiers.compactMap({
            guard case .course(id: let id) = $0 else { return nil }

            return id
        })

        let fetchPredicate = #Predicate<CachedCourse> {
            courseIdentifiers.contains($0.id)
        }
        let fetchDescriptor = FetchDescriptor<CachedCourse>(predicate: fetchPredicate)

        let courses = try modelContext.fetch(fetchDescriptor).compactMap({ Course(from: $0) })
        await indexCoursesIntoSpotlight(courses)
    }

    func reindexCAnnouncementItems(_ identifiers: [SpotlightContentType]) async throws {
        var idMappings: Dictionary<Course.ID, [CourseAnnouncement.ID]> = [:]
        for identifier in identifiers {
            guard case .courseAnnouncement(id: let id, courseId: let courseId) = identifier else { continue }

            if idMappings.keys.contains(courseId) {
                idMappings[courseId]?.append(id)
            } else {
                idMappings[courseId] = [id]
            }
        }

        try await withThrowingTaskGroup { group in
            for mapping in idMappings {
                let cAnnouncementIds = mapping.value
                let courseId = mapping.key

                let fetchPredicate = #Predicate<CachedCourseAnnouncement> { cAnnouncementIds.contains($0.id) && $0.course?.id == courseId }
                let fetchDescriptor = FetchDescriptor<CachedCourseAnnouncement>(predicate: fetchPredicate)

                let cAnnouncements = try modelContext.fetch(fetchDescriptor).compactMap({ CourseAnnouncement(from: $0) })

                // Hmmmmmmm, seems suspicious
                group.addTask { await self.indexCourseAnnouncementsIntoSpotlight(cAnnouncements, for: mapping.key) }
            }

            return try await group.next()
        }
    }

    enum SpotlightContentType {
        case course(id: Course.ID)
        case courseAnnouncement(id: CourseAnnouncement.ID, courseId: Course.ID)

        init?(from spotlightIdentifier: String) {
            let path = spotlightIdentifier.split(separator: "/")

            guard path.count > 0 else { return nil }

            switch path[0] {
                case "course":
                    guard path.count == 2 else {
                        BbCache.logger.warning("Course Spotlight item is missing ID, unable to index.")
                        return nil
                    }

                    self = .course(id: String(path[1]))
                    break
                case "announcement":
                    guard path.count == 3 else {
                        BbCache.logger.warning("Course Announcement Spotlight item is missing an ID, unable to index.")
                        return nil
                    }

                    self = .courseAnnouncement(id: String(path[2]), courseId: String(path[1]))
                default:
                    BbCache.logger.warning("Unknown Spotlight identifier group '\(path[0])'")
                    return nil
            }

            return nil
        }
    }
}
