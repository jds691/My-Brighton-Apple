//
//  Module.swift
//  My Brighton
//
//  Created by Neo Salmon on 28/06/2025.
//

import Foundation

@available(*, deprecated, renamed: "Course", message: "LearnKit Course is now implemented")
nonisolated
struct Module: Identifiable {
    var id: String { courseId }
    
    let courseId: String
    let displayId: String
    let name: String
    let image: Self.Image
    
    enum Image {
        case named(_ imageName: String)
        case remote(url: URL)
    }
    
    static let modules: [Module] = [
        .init(courseId: "0", displayId: "CI512", name: "Intelligent Systems 1", image: .named("Thumbnails/nature5_thumb")),
        .init(courseId: "1", displayId: "CI513", name: "Intelligent Systems 2", image: .named("Thumbnails/nature1_thumb")),
        .init(courseId: "2", displayId: "CI514", name: "Embedded Systems", image: .named("Thumbnails/nature11_thumb")),
        .init(courseId: "3", displayId: "CI536", name: "Integrated Group Project", image: .named("Thumbnails/nature14_thumb")),
        .init(courseId: "4", displayId: "CI553", name: "Object orientated development and testing", image: .named("Thumbnails/nature1_thumb")),
        .init(courseId: "5", displayId: "CI583", name: "Data Structures and Operating Systems", image: .named("Thumbnails/nature20_thumb"))
    ]
}
