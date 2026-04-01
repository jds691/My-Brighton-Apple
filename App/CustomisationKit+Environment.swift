//
//  CustomisationKit+Environment.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftUI
import CustomisationKit

extension EnvironmentValues {
    @Entry var customisationService: CustomisationService = CustomisationService(inMemory: true)
}
