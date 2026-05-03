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
import UniformTypeIdentifiers

/// Handles all SwiftData and offline caching operations.
///
/// BbCache manages all offline operations for Learn API REST information. It will:
/// - Indexes information received from the API into SwiftData
/// - Indexes SwiftData information into CoreSpotlight
actor BbCache {
    private static let logger: Logger = Logger(subsystem: "com.neo.LearnKit", category: "BbCache")
    private static let schemaV1: Schema = .init([
        CachedCourse.self,
        CachedContent.self,
        CachedTerm.self,
        CachedSystemAnnouncement.self,
        CachedCourseAnnouncement.self,
        CachedGradeColumn.self,
        CachedGradebookAttempt.self
    ])

    // TODO: Consider protection class
    private let searchableIndex: CSSearchableIndex = CSSearchableIndex(name: "LearnKit")

    private var modelExecutor: any ModelExecutor
    private var modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }

    private let wasInitInMemory: Bool

    /// Initialises the cache database with the current schema version.
    init() {
        self.wasInitInMemory = false
        do {
            let config: ModelConfiguration = .init("BbCache", schema: Self.schemaV1, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: Self.schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }
    
    /// Initialises a version of the cache database designed for testing and previews.
    /// - Parameter inMemoryOnly: Indicates if the database is in-memory only, useful for initialising many instances in test suites,
    init(inMemoryOnly: Bool) {
        self.wasInitInMemory = inMemoryOnly
        do {
            let config: ModelConfiguration = .init("BbCache", schema: Self.schemaV1, isStoredInMemoryOnly: inMemoryOnly, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: Self.schemaV1, configurations: config)
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
            let customisations = CustomisationService.shared.getCourseCustomisation(for: course.id)

            let courseAppEntity = CourseEntity(from: course, with: customisations)
            let courseAttributes = CSSearchableItemAttributeSet()

            courseAttributes.title = course.name
            courseAttributes.displayName = customisations.displayNameOverride ?? course.name
            courseAttributes.contentDescription = course.description
            courseAttributes.alternateNames = [
                course.id,
                course.courseId,
                course.externalAccessUrl.absoluteString
            ]

            if customisations.displayNameOverride != nil {
                courseAttributes.alternateNames?.append(course.name)
            }

            courseAttributes.keywords = [
                "course",
                "module",
                "Blackboard",
                course.courseId
            ]
            courseAttributes.metadataModificationDate = course.lastModified
            courseAttributes.thumbnailURL = CustomisationService.shared.thumbnailUrl(for: course.id, nilIfNonExistent: true)

            let courseCsItem = CSSearchableItem(uniqueIdentifier: "course/\(course.id)", domainIdentifier: nil, attributeSet: courseAttributes)
            courseCsItem.associateAppEntity(courseAppEntity)

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
        let course: Course? = try? await getCourse(for: courseIdentifier)

        var csItems: [CSSearchableItem] = []
        for announcement in announcements {
            let cAnnouncementAttributes = CSSearchableItemAttributeSet(contentType: UTType.message)

            cAnnouncementAttributes.title = announcement.title
            cAnnouncementAttributes.displayName = announcement.title
            cAnnouncementAttributes.alternateNames = [
                announcement.id,
            ]
            cAnnouncementAttributes.keywords = [
                "announcement",
                "Blackboard",
                announcement.id
            ]
            if let chunks = try? BbMLParser().parse(announcement.body) {
                cAnnouncementAttributes.textContent = returnBbMLText(from: chunks)

                for chunk in chunks {
                    if case .document(url: let url, attachmentInfo: let attachmentInfo) = chunk {
                        cAnnouncementAttributes.alternateNames?.append(attachmentInfo.name)
                    }
                }
            }
            cAnnouncementAttributes.metadataModificationDate = announcement.lastModifiedDate
            let cAnnouncementCsItem = CSSearchableItem(uniqueIdentifier: "announcement/\(courseIdentifier)/\(announcement.id)", domainIdentifier: nil, attributeSet: cAnnouncementAttributes)
            if case .restricted(start: _, end: let end) = announcement.availability {
                cAnnouncementCsItem.expirationDate = end
            }

            if let course {
                cAnnouncementAttributes.containerIdentifier = course.id
                cAnnouncementAttributes.containerTitle = course.name
                cAnnouncementAttributes.containerDisplayName = course.name
                cAnnouncementAttributes.containerOrder = NSNumber(integerLiteral: announcement.positionIndex)
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
                let cachedGradeColumn: CachedGradeColumn? = try await getGradeColumn(for: column.id, in: courseIdentifier)

#if DEBUG
                assert(cachedCourse != nil)
#endif

                if let existingCachedGradeColumn = cachedGradeColumn {
                    existingCachedGradeColumn.copyValues(from: column)
                    existingCachedGradeColumn.course = cachedCourse
                } else {
                    let newCachedGradeColumn = CachedGradeColumn(from: column)
                    newCachedGradeColumn.course = cachedCourse

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
        async let contentIndexing: () = indexCourseContentIntoSpotlight(content, for: courseIdentifier)

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

        await contentIndexing
    }

    private func indexCourseContentIntoSpotlight(_ content: [Content], for courseId: Course.ID) async {
        let course: Course? = try? await getCourse(for: courseId)
        var csItems: [CSSearchableItem] = []
        for contentItem in content {
            // Filters ROOT folder and BbPage children
            if contentItem.parentId == nil || contentItem.title == "ultraDocumentBody" { continue }

            let parent: Content?
            if let parentId = contentItem.parentId {
                parent = try? await getContent(for: parentId, in: courseId)
            } else {
                parent = nil
            }

            let contentAttributes = CSSearchableItemAttributeSet()

            contentAttributes.title = contentItem.title
            contentAttributes.displayName = contentItem.title
            contentAttributes.contentDescription = contentItem.description
            if let body = contentItem.body, !body.isEmpty {
                contentAttributes.textContent = returnBbMLText(body)
            }

            contentAttributes.keywords = [
                "content",
                "Blackboard"
            ]
            contentAttributes.metadataModificationDate = contentItem.lastModified
            contentAttributes.contentModificationDate = contentItem.lastModified
            contentAttributes.identifier = contentItem.id

            if let parent {
                contentAttributes.containerIdentifier = parent.id
                contentAttributes.containerTitle = parent.title
                if parent.title == "ROOT" {
                    contentAttributes.containerDisplayName = course?.name
                } else {
                    contentAttributes.containerDisplayName = (course?.name ?? "") + " - " + parent.title
                }
                contentAttributes.containerOrder = NSNumber(integerLiteral: contentItem.positionIndex)
            } else if let course {
                contentAttributes.containerIdentifier = course.id
                contentAttributes.containerTitle = course.name
                contentAttributes.containerDisplayName = course.name
                contentAttributes.containerOrder = NSNumber(integerLiteral: contentItem.positionIndex)
            }

            switch contentItem.handler {
                case .contentItem:
                    contentAttributes.setValue(NSString("richtext.page"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    if let body = contentItem.body, let chunks = try? BbMLParser().parse(body) {
                        contentAttributes.textContent = returnBbMLText(from: chunks)

                        for chunk in chunks {
                            if case .document(url: let url, attachmentInfo: let attachmentInfo) = chunk {
                                contentAttributes.alternateNames?.append(attachmentInfo.name)
                            }
                        }
                    }
                case .externalLink(let url):
                    contentAttributes.setValue(NSString("globe"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    contentAttributes.keywords?.append("link")
                    contentAttributes.contentType = UTType.url.identifier
                    contentAttributes.contentURL = url
                case .contentFolder(isBbPage: let isBbPage):
                    contentAttributes.contentType = UTType.folder.identifier
                    contentAttributes.setValue(isBbPage ? NSString("richtext.page") : NSString("folder"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    if !isBbPage {
                        contentAttributes.keywords?.append("folder")
                    } else {
                        if let ultraDocumentChild = try? await getChildContent(for: contentItem.id, in: courseId).first {
                            if let body = contentItem.body, let chunks = try? BbMLParser().parse(body) {
                                contentAttributes.textContent = returnBbMLText(from: chunks)

                                for chunk in chunks {
                                    if case .document(url: let url, attachmentInfo: let attachmentInfo) = chunk {
                                        contentAttributes.alternateNames?.append(attachmentInfo.name)
                                    }
                                }
                            }
                        }
                    }
                case .contentLesson:
                    contentAttributes.contentType = UTType.folder.identifier
                    contentAttributes.setValue(NSString("graduationcap"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    contentAttributes.keywords?.append(contentsOf: ["folder", "lesson"])
                case .courseLink(target: _):
                    contentAttributes.setValue(NSString("globe"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                case .discussionLink(target: _):
                    contentAttributes.setValue(NSString("questionmark"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                case .ltiLink(_, parameters: _):
                    contentAttributes.setValue(NSString("globe.desk"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                case .contentFile(uploadId: _, fileName: _, mimeType: let mimeType, duplicateFileHandling: _):
                    let iconName: NSString
                    if let utType = UTType(mimeType: mimeType) {
                        contentAttributes.contentType = utType.identifier
                        switch utType {
                            case .image:
                                iconName = NSString("photo")
                                contentAttributes.keywords?.append("image")
                            case .pdf:
                                iconName = NSString("append.page")
                                contentAttributes.keywords?.append("PDF")
                            case .presentation:
                                iconName = NSString("rectangle.on.rectangle.angled")
                                contentAttributes.keywords?.append("presentation")
                            default:
                                iconName = NSString("questionmark")
                        }
                    } else {
                        contentAttributes.contentType = UTType.item.identifier
                        iconName = NSString("questionmark")
                    }

                    contentAttributes.setValue(iconName, forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    contentAttributes.keywords?.append("file")
                case .testLink(target: _, gradeColumn: _):
                    contentAttributes.setValue(NSString("questionmark.text.page"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    contentAttributes.keywords?.append("assignment")
                case .assignment(gradeColumn: _, isGroup: _):
                    contentAttributes.setValue(NSString("questionmark.text.page"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
                    contentAttributes.keywords?.append("assignment")
                case .ltiPlacement:
                    contentAttributes.setValue(NSString("questionmark"), forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey)
            }

            let contentCsItem = CSSearchableItem(uniqueIdentifier: "content/\(courseId)/\(contentItem.id)", domainIdentifier: nil, attributeSet: contentAttributes)

            csItems.append(contentCsItem)
        }

        do {
            try await searchableIndex.indexSearchableItems(csItems)
        } catch {
            Self.logger.error("Spotlight indexing error for course contents: \(error)")
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
    // MARK: Caching
    func eraseAllCache() async throws(LearnKitError) {
        do {
            try await searchableIndex.deleteAllSearchableItems()
        } catch {
        }

        do {
            try modelContainer.erase()
            initialiseModelContainer()
        } catch {
            throw .cacheEraseFailed
        }
    }

    private func initialiseModelContainer() {
        do {
            let config: ModelConfiguration = .init("BbCache", schema: Self.schemaV1, isStoredInMemoryOnly: self.wasInitInMemory, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: Self.schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

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

        return gradeColumn.attempts.sorted(by: { $0.created > $1.created })
    }

    func getGradebookAttempt(by attemptId: GradebookAttempt.ID, for columnIdentifier: GradeColumn.ID, in course: Course.ID) async throws -> CachedGradebookAttempt? {
        let predicate = #Predicate<CachedGradebookAttempt> { cachedAttempt in
            if let associatedGradeColumn = cachedAttempt.associatedGradeColumn, let columnCourse = associatedGradeColumn.course {
                return cachedAttempt.id == attemptId && associatedGradeColumn.id == columnIdentifier && columnCourse.id == course
            } else {
                return false
            }
        }
        var descriptor = FetchDescriptor<CachedGradebookAttempt>(predicate: predicate)
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
        let predicate = #Predicate<CachedGradebookAttempt> { cachedAttempt in
            if let associatedGradeColumn = cachedAttempt.associatedGradeColumn, let columnCourse = associatedGradeColumn.course {
                return associatedGradeColumn.id == columnIdentifier && columnCourse.id == course
            } else {
                return false
            }
        }

        var descriptor = FetchDescriptor<CachedGradebookAttempt>(
            predicate: predicate,
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
    private func returnBbMLText(from content: BbMLContent) -> String? {
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

        await withTaskGroup(isolation: self) { group in
            group.addTask { [self] in
                await indexCoursesIntoSpotlight(courses)
            }

            for course in courses {
                do {
                    let courseId: String = course.id
                    let courseAnnouncementsFetchDescriptor = FetchDescriptor<CachedCourseAnnouncement>(predicate: #Predicate { $0.course?.id == courseId })
                    let courseAnnouncements = try modelContext.fetch(courseAnnouncementsFetchDescriptor).compactMap({ CourseAnnouncement(from: $0) })

                    let courseContentFetchDescriptor = FetchDescriptor<CachedContent>(predicate: #Predicate { $0.course?.id == courseId })
                    let courseContent = try modelContext.fetch(courseContentFetchDescriptor).compactMap({ Content(from: $0) })

                    group.addTask { [self] in
                        await indexCourseAnnouncementsIntoSpotlight(courseAnnouncements, for: course.id)
                        await indexCourseContentIntoSpotlight(courseContent, for: courseId)
                    }
                } catch {
                }
            }

            await group.waitForAll()
        }
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
        let courseContentItems = spotlightItems.filter({
            if case .courseContent(id: _, courseId: _) = $0 {
                return true
            } else {
                return false
            }
        })

        async let courseIndexing: () = reindexCourseItems(courseItems)
        async let cAnnouncementIndexing: () = reindexCAnnouncementItems(cAnnouncementItems)
        async let courseContentIndexing: () = reindexCourseContentItems(courseContentItems)

        try await courseIndexing
        try await cAnnouncementIndexing
        try await courseContentIndexing
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

    func reindexCourseContentItems(_ identifiers: [SpotlightContentType]) async throws {
        var idMappings: Dictionary<Course.ID, [Content.ID]> = [:]
        for identifier in identifiers {
            guard case .courseContent(id: let id, courseId: let courseId) = identifier else { continue }

            if idMappings.keys.contains(courseId) {
                idMappings[courseId]?.append(id)
            } else {
                idMappings[courseId] = [id]
            }
        }

        try await withThrowingTaskGroup { group in
            for mapping in idMappings {
                let contentIds = mapping.value
                let courseId = mapping.key

                let fetchPredicate = #Predicate<CachedContent> { contentIds.contains($0.id) && $0.course?.id == courseId }
                let fetchDescriptor = FetchDescriptor<CachedContent>(predicate: fetchPredicate)

                let contents = try modelContext.fetch(fetchDescriptor).compactMap({ Content(from: $0) })

                // Hmmmmmmm, seems suspicious
                group.addTask { await self.indexCourseContentIntoSpotlight(contents, for: mapping.key) }
            }

            try await group.waitForAll()
        }
    }

    enum SpotlightContentType {
        case course(id: Course.ID)
        case courseAnnouncement(id: CourseAnnouncement.ID, courseId: Course.ID)
        case courseContent(id: Content.ID, courseId: Course.ID)

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
                case "content":
                    guard path.count == 3 else {
                        BbCache.logger.warning("Course Content Spotlight item is missing an ID, unable to index.")
                        return nil
                    }

                    self = .courseContent(id: String(path[2]), courseId: String(path[1]))
                default:
                    BbCache.logger.warning("Unknown Spotlight identifier group '\(path[0])'")
                    return nil
            }

            return nil
        }
    }
}
