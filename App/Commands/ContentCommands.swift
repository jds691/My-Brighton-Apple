//
//  ContentCommands.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/08/2025.
//

import LearnKit
import SwiftUI

struct ContentCommands: Commands {
    var body: some Commands {
        CommandMenu("Content") {
        }
    }
}

extension FocusedValues {
    @Entry var contentId: Content.ID?
}
