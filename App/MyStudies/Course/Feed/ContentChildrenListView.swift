//
//  ContentChildrenList.swift
//  My Brighton
//
//  Created by Neo Salmon on 24/11/2025.
//

import SwiftUI
import LearnKit
import Router

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
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(children, id: \.id) { child in
                        NavigationLink(value: getNavDestination(for: child)) {
                            ContentListCard(for: child)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task(id: contentId) {
            do {
                async let modifiedChildren = try learnKit.refreshContent(for: contentId, includeChildren: true, in: courseId)

                children = try await learnKit.getChildContent(for: contentId, in: courseId)

                if try await modifiedChildren.isEmpty { return }

                try await mergeChildren(with: modifiedChildren)
            } catch {
                print(error)
            }
        }
    }

    private func mergeChildren(with contents: [Content]) {
        for newContent in contents {
            if newContent.id == self.contentId { continue }
            
            if let replacementIndex = children.firstIndex(where: { $0.id == newContent.id }) {
                children[replacementIndex] = newContent
            } else {
                children.append(newContent)
            }
        }

        children.sort(by: { $0.positionIndex < $1.positionIndex })
    }

    private func getNavDestination(for content: Content) -> any Hashable {
        switch content.handler {
            case .contentItem, .contentFolder(isBbPage: _):
                return Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.content(content.id)
            default:
                return -1
        }
    }
}
