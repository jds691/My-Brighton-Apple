//
//  CourseEntity.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//
import AppIntents
import CustomisationKit

public struct CourseEntity: AppEntity {
    @AppDependency
    private var learnKit: LearnKitService

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Course")
    }
    
    public var displayRepresentation: DisplayRepresentation {
        let customisations = CustomisationService.shared.getCourseCustomisation(for: self.id)

        if let thumbnailUrl = CustomisationService.shared.thumbnailUrl(for: self.id, nilIfNonExistent: true) {
            return .init(title: "\(customisations.displayNameOverride ?? self.name)", image: .init(url: thumbnailUrl))
        } else {
            return .init(title: "\(customisations.displayNameOverride ?? self.name)", image: .init(systemName: "books.vertical", isTemplate: true))
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
