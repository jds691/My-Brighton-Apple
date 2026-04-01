//
//  CourseCustomisations.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public final class CourseCustomisation {
    @Attribute(.unique)
    public internal(set) var courseId: String
    
    public var isFavourite: Bool
    public var displayNameOverride: String?
    public var textAlignment: Alignment
    public var fontDesign: FontDesign
    public var textColorOverride: Color?

    init() {
        self.courseId = ""
        self.isFavourite = false
        self.displayNameOverride = nil
        self.textAlignment = .bottomLeading
        self.fontDesign = .regular
        self.textColorOverride = nil
    }
}
