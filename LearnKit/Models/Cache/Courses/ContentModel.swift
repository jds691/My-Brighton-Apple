//
//  ContentModel.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/08/2025.
//

import Foundation
import SwiftData

@Model
class ContentModel: Identifiable {
    public var id: Content.ID
    //public var course: CourseModel

    init() {
        self.id = ""
    }
}
