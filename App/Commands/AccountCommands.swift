//
//  AccountCommands.swift
//  My Brighton
//
//  Created by Neo Salmon on 24/06/2025.
//

import SwiftUI

struct AccountCommands: Commands {
    var body: some Commands {
        CommandGroup(before: .appTermination) {
            Button("Sign Out") {
                
            }
        }
    }
}
