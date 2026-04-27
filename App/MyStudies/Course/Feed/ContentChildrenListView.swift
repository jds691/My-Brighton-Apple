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
struct ContentChildrenListView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(\.learnKitService) private var learnKit
    @Environment(\.courseId) private var courseId

    private var contentId: Content.ID

    @State private var children: [Content] = []

    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String? = nil
    @State private var errorCausedDuringInit: Bool = false

    init(for contentIdentifier: Content.ID) {
        self.contentId = contentIdentifier
    }

    var body: some View {
        Group {
            if children.isEmpty {
                NoContentView("No Content")
                    .frame(minHeight: 80)
            } else {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(children, id: \.id) { child in
                        ContentListCard(for: child)
                            .modifier(ContentListCardInteractionViewModifier(child))
                    }
                }
            }
        }
        .task(id: contentId) {
            await initView()
        }
        .refreshable {
            do {
                let modifiedChildren = try await learnKit.refreshContent(for: contentId, includeChildren: true, in: courseId!)
                if modifiedChildren.isEmpty { return }

                mergeChildren(with: modifiedChildren)
            } catch {
                errorCausedDuringInit = false
                showErrorMessage = true
                print(error)
            }
        }
        .alert("Unable to load content", isPresented: $showErrorMessage) {
            if errorCausedDuringInit {
                Button("Retry") {
                    errorMessage = nil
                    Task {
                        await initView()
                    }
                }
            }

            Button("Cancel", role: .cancel) {
                dismiss()
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            } else {
                Text("An unknown error occurred.")
            }
        }
    }

    private func initView() async {
        do {
            try await learnKit.refreshContent(for: contentId, includeChildren: true, in: courseId!)
            children = try await learnKit.getChildContent(for: contentId, in: courseId!)
        } catch {
            errorCausedDuringInit = true
            showErrorMessage = true
            print(error)
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
}
