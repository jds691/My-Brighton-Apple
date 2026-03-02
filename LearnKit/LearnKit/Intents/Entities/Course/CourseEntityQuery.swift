//
//  CourseEntityQuery.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//

import AppIntents

/*public struct FavouriteCourseEntityQuery: EntityStringQuery {
    public init() {

    }

    public func entities(matching string: String) async throws -> [CourseEntity] {
        return []
    }
    
    public func entities(for identifiers: [Course.ID]) async throws -> [CourseEntity] {
        return []
    }
    
    public func suggestedEntities() async throws -> [Entity] {
        return []
    }
    
    public typealias Entity = CourseEntity
}*/

public struct CourseEntityQuery: EntityStringQuery {
    @AppDependency
    private var learnKit: LearnKitService

    public init() {

    }

    public func entities(matching string: String) async throws -> [CourseEntity] {
        return try await withThrowingTaskGroup(of: CourseEntity.self, returning: [CourseEntity].self) { group in
            let courseModels = try await learnKit.getAllCourses().filter { $0.name.lowercased().contains(string.lowercased()) }

            for model in courseModels {
                group.addTask {
                    await CourseEntity(from: model)
                }
            }

            var entities = [CourseEntity]()
            for try await result in group {
                entities.append(result)
            }
            return entities
        }
    }
    
    public func entities(for identifiers: [Course.ID]) async throws -> [CourseEntity] {
        return try await withThrowingTaskGroup(of: CourseEntity.self, returning: [CourseEntity].self) { group in
            let courseModels = try await learnKit.getAllCourses().filter { identifiers.contains($0.id) }

            for model in courseModels {
                group.addTask {
                    await CourseEntity(from: model)
                }
            }

            var entities = [CourseEntity]()
            for try await result in group {
                entities.append(result)
            }
            return entities
        }
    }
    
    public func suggestedEntities() async throws -> [Entity] {
        return try await withThrowingTaskGroup(of: CourseEntity.self, returning: [CourseEntity].self) { group in
            let courseModels = try await learnKit.getAllCourses()

            for model in courseModels {
                group.addTask {
                    await CourseEntity(from: model)
                }
            }

            var entities = [CourseEntity]()
            for try await result in group {
                entities.append(result)
            }
            return entities
        }
    }
    
    public typealias Entity = CourseEntity
}
