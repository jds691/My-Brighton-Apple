//
//  HomeCustomisation.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public final class HomeCustomisation {
    public var profilePictureOverrideUrl: URL?
    public var displayNameOverride: String?
    public var background: BackgroundType
    public var fontDesign: FontDesign
    public var textColor: CodableColor
    public var textEffects: TextEffects

    public init() {
        self.profilePictureOverrideUrl = nil
        self.displayNameOverride = nil
        self.background = .builtInImage("placeholder/StudentIdBanner")
        self.fontDesign = .regular
        self.textColor = CodableColor.fromColor(.white)
        self.textEffects = []
    }
}
