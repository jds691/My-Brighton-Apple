//
//  CourseModel.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/08/2025.
//

import Foundation
import SwiftData

@Model
class CourseModel: Identifiable {
    var id: Course.ID

    //@Relationship(inverse: \ContentModel.course)
    //public var content: [ContentModel]

    public init() {
        id = ""
    }
}
