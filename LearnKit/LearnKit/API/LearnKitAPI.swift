//
//  LearnKitAPI.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/09/2025.
//

/// Collection of methods required to be implemented by the service and offline cache actor.
protocol LearnKitAPI {
    // MARK: Courses
    /// Gets a list of all courses stored in the service.
    /// - Returns: All courses stored into the service.
    func getAllCourses() async throws -> [Course]
    /// Gets a course, specified by its ID, from the service.
    /// - Parameter identifier: Identifier of the course.
    /// - Returns: The course, if found, or nil.
    func getCourse(for identifier: Course.ID) async throws -> Course?

    // MARK: Content
    /// Gets a list of all root content inside of the course.
    /// - Parameter course: Identifier of the course to load content for.
    /// - Returns: All root content stored in the course.
    func getAllContent(in course: Course.ID) async throws -> [Content]
    /// Gets a list of all child content within a parent content item.
    /// - Parameter content: Identifier of the parent content item to load children of.
    /// - Returns: All children of the parent content item.
    func getChildContent(for identifier: Content.ID, in course: Course.ID) async throws -> [Content]
    /// Gets a content item, specified by its ID, from the service.
    /// - Parameters:
    ///   - identifier: Identifier of the content item.
    ///   - course: Identifier of the course the content is contained within.
    /// - Returns: The content item, if found, or nil.
    func getContent(for identifier: Content.ID, in course: Course.ID) async throws -> Content?

    // MARK: Terms
    /// Gets a list of all terms stored in the service.
    /// - Returns: All terms stored into the service.
    func getAllTerms() async throws -> [Term]
    /// Gets a term, specified by its ID, from the service.
    /// - Parameter identifier: Identifier of the term.
    /// - Returns: The term, if found, or nil.
    func getTerm(for identifier: Term.ID) async throws -> Term?
}
