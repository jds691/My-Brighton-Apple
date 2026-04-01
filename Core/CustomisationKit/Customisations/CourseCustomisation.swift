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
    private var courseId: String
    private var isFavourite: Bool
    private var displayNameOverride: String?
    private var textAlignment: Alignment
    private var fontDesign: FontDesign
    private var textColorOverride: Color?

    init() {
        self.courseId = ""
        self.isFavourite = false
        self.displayNameOverride = nil
        self.textAlignment = .bottomLeading
        self.fontDesign = .regular
        self.textColorOverride = nil
    }
}
