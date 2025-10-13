//
//  LearnKitAPI.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/09/2025.
//

/// Collection of methods required to be implemented by the service and offline cache actor.
///
/// Only API calls that result in data that should be persisted offline are included. The following groups of API are not included:
/// - Authentication
protocol LearnKitAPI {
    // MARK: Courses
    func getAllCourses() async throws -> [Course]
    func getCourse(for identifier: Course.ID) async throws -> Course?

    // MARK: Terms
    func getAllTerms() async throws -> [Term]
    func getTerm(for identifier: Term.ID) async throws -> Term?
}
