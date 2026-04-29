//
//  ContentFolderView.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import LearnKit
import Router

struct ContentFolderView: View {
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.courseId) private var courseId

    @Binding var content: Content

    init(content: Binding<Content>) {
        self._content = content
    }
    var body: some View {
        ScrollView {
            ContentChildrenListView(for: content.id)
        }
        .myBrightonBackground()
        .contentMargins(16, for: .scrollContent)
        .navigationTitle(content.title)
    }
}
