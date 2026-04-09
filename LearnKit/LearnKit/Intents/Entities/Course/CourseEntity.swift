//
//  CourseEntity.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//
import AppIntents

public struct CourseEntity: AppEntity {
    @AppDependency
    private var learnKit: LearnKitService

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Course")
    }
    
    public var displayRepresentation: DisplayRepresentation {
        if let provider = learnKit.getDisplayRepresentationProvider(for: Self.self), let representation = provider.representation(for: self) {
            return representation
        } else {
            return .init(title: "\(name)", image: .init(systemName: "books.vertical", isTemplate: true))
        }
    }
    
    public static let defaultQuery = CourseEntityQuery()

    @Property(title: "ID")
    public var id: Course.ID

    @Property(title: "Name")
    public var name: String

    public init(from courseModel: Course) async {
        self.id = courseModel.id
        self.name = courseModel.name
    }
}

extension CourseEntity: URLRepresentableEntity {
    public static var urlRepresentation: URLRepresentation {
        "https://studentcentral.brighton.ac.uk/ultra/courses/\(.id)/outline"
    }
}

extension CourseEntity: IndexedEntity {}
