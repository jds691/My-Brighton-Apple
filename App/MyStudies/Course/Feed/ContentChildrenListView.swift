//
//  ContentChildrenList.swift
//  My Brighton
//
//  Created by Neo Salmon on 24/11/2025.
//

import SwiftUI
import LearnKit
import CoreDesign
import Router

// TODO: Remove forced unwraps
// TODO: Show alert and dismiss on errors
struct ContentChildrenListView: View {
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.courseId) private var courseId

    private var contentId: Content.ID

    @State private var children: [Content] = []

    init(for contentIdentifier: Content.ID) {
        self.contentId = contentIdentifier
    }

    var body: some View {
        Group {
            if children.isEmpty {
                NoContentView("No Content")
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
                try await learnKit.refreshContent(for: contentId, includeChildren: true, in: courseId!)
                children = try await learnKit.getChildContent(for: contentId, in: courseId!)
            } catch {
                print(error)
            }
        }
        .refreshable {
            do {
                let modifiedChildren = try await learnKit.refreshContent(for: contentId, includeChildren: true, in: courseId!)
                if modifiedChildren.isEmpty { return }

                mergeChildren(with: modifiedChildren)
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
