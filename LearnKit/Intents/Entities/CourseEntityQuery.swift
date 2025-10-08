//
//  CourseEntityQuery.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//

import AppIntents

public struct FavouriteCourseEntityQuery: EntityStringQuery {
    let demoCourses: [CourseEntity] = [
        .init(id: "0", name: "Intelligent Systems 1", imageName: "Thumbnails/nature5_thumb"),
        .init(id: "1", name: "Intelligent Systems 2", imageName: "Thumbnails/nature1_thumb"),
        .init(id: "2", name: "Embedded Systems", imageName: "Thumbnails/nature11_thumb")
    ]

    public init() {

    }

    public func entities(matching string: String) async throws -> [CourseEntity] {
        return demoCourses.filter { $0.name.contains(string) }
    }
    
    public func entities(for identifiers: [Course.ID]) async throws -> [CourseEntity] {
        return demoCourses.filter { identifiers.contains($0.id) }
    }
    
    public func suggestedEntities() async throws -> [Entity] {
        return demoCourses
    }
    
    public typealias Entity = CourseEntity
}

public struct CourseEntityQuery: EntityStringQuery {
    let demoCourses: [CourseEntity] = [
        .init(id: "0", name: "Intelligent Systems 1", imageName: "Thumbnails/nature5_thumb"),
        .init(id: "1", name: "Intelligent Systems 2", imageName: "Thumbnails/nature1_thumb"),
        .init(id: "2", name: "Embedded Systems", imageName: "Thumbnails/nature11_thumb"),
        .init(id: "3", name: "Integrated Group Project", imageName: "Thumbnails/nature14_thumb"),
        .init(id: "4", name: "Object orientated development and testing", imageName: "Thumbnails/nature1_thumb"),
        .init(id: "5", name: "Data Structures and Operating Systems", imageName: "Thumbnails/nature20_thumb")
    ]

    public init() {

    }

    public func entities(matching string: String) async throws -> [CourseEntity] {
        return demoCourses.filter { $0.name.contains(string) }
    }
    
    public func entities(for identifiers: [Course.ID]) async throws -> [CourseEntity] {
        return demoCourses.filter { identifiers.contains($0.id) }
    }
    
    public func suggestedEntities() async throws -> [Entity] {
        return demoCourses
    }
    
    public typealias Entity = CourseEntity
}
