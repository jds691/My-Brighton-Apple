//
//  ModuleGradesView.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/07/2025.
//

import SwiftUI

struct ModuleGradesView: View {
    var body: some View {
        List {
            Text("Test")
        }
        .navigationTitle("Grades")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        ModuleGradesView()
    }
}
