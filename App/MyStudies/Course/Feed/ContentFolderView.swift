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
    private let courseId: Course.ID

    @Binding var content: Content

    init(content: Binding<Content>, courseId: Course.ID) {
        self._content = content
        self.courseId = courseId
    }
    var body: some View {
        ScrollView {
            ContentChildrenListView(for: content.id, in: courseId)
        }
        .contentMargins(16, for: .scrollContent)
        .navigationTitle(content.title)
    }
}
