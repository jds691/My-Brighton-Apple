//
//  BackgroundType.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftUI

public enum BackgroundType: Codable {
    case color(Color)
    case builtInImage(String)
}
