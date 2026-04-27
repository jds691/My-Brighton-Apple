//
//  CourseEntityQuery.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//

import AppIntents
import CustomisationKit

public struct CourseEntityQuery: EntityStringQuery {
    @AppDependency
    private var learnKit: LearnKitService

    public init() {

    }

    public func entities(matching string: String) async throws -> [CourseEntity] {
        let courseModels = try await learnKit.getAllCourses().filter { $0.name.lowercased().contains(string.lowercased()) }

        var entities = [CourseEntity]()
        for model in courseModels {
            let customisations = CustomisationService.shared.getCourseCustomisation(for: model.id)
            entities.append(CourseEntity(from: model, with: customisations))
        }

        return entities
    }
    
    public func entities(for identifiers: [Course.ID]) async throws -> [CourseEntity] {
        let courseModels = try await learnKit.getAllCourses().filter { identifiers.contains($0.id) }

        var entities = [CourseEntity]()
        for model in courseModels {
            let customisations = CustomisationService.shared.getCourseCustomisation(for: model.id)
            entities.append(CourseEntity(from: model, with: customisations))
        }

        return entities
    }
    
    public func suggestedEntities() async throws -> [Entity] {
        let courseModels = try await learnKit.getAllCourses()

        var entities = [CourseEntity]()
        for model in courseModels {
            let customisations = CustomisationService.shared.getCourseCustomisation(for: model.id)
            entities.append(CourseEntity(from: model, with: customisations))
        }

        return entities
    }
    
    public typealias Entity = CourseEntity
}
