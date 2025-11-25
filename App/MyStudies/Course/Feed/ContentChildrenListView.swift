//
//  ContentChildrenList.swift
//  My Brighton
//
//  Created by Neo Salmon on 24/11/2025.
//

import SwiftUI
import LearnKit

struct ContentChildrenListView: View {
    @Environment(\.learnKitService) private var learnKit

    private var courseId: Course.ID
    private var contentId: Content.ID

    @State private var children: [Content] = []

    init(for contentIdentifier: Content.ID, in courseIdentifier: Course.ID) {
        self.contentId = contentIdentifier
        self.courseId = courseIdentifier
    }

    var body: some View {
        Group {
            if children.isEmpty {
                Text("No Children")
            } else {
                LazyVStack {
                    ForEach(children, id: \.id) { child in
                        Text(child.title)
                    }
                }
            }
        }
        .task(id: contentId) {
            do {
                children = try await learnKit.getChildContent(for: contentId, in: courseId)
            } catch {
                print(error)
            }
        }
    }
}
