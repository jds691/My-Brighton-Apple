//
//  CourseEntity.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//
import AppIntents

public struct CourseEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Course")
    }
    
    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)", image: .init(named: imageName))
    }
    
    public static let defaultQuery = CourseEntityQuery()

    @Property(title: "ID")
    public var id: String

    @Property(title: "Name")
    public var name: String
    @Property(title: "Image Name")
    public var imageName: String

    public init(id: String, name: String, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}

extension CourseEntity: URLRepresentableEntity {
    public static var urlRepresentation: URLRepresentation {
        "https://studentcentral.brighton.ac.uk/ultra/courses/\(.id)/outline"
    }
}

extension CourseEntity: IndexedEntity {}
