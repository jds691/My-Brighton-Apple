//
//  BbMLContentViewer.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/08/2025.
//

@preconcurrency import Translation
import SwiftBbML
import SwiftUI
import CoreDesign
import Router
import LearnKit

struct BbMLContentViewer: View {
    @Environment(Router.self) private var router
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.locale) private var currentLocale
    @Environment(\.courseId) private var courseId
    @Environment(\.dismiss) private var dismiss

    @Binding private var content: Content

    @State private var bbML: BbMLContent = BbMLContent(header: nil, chunks: [])
    @State private var displayBbML: BbMLContent = BbMLContent(
        header: nil,
        chunks: []
    )

    @State private var isLoading: Bool = true

    @State private var showLoadFailedMessage: Bool = false
    @State private var loadFailedMessage: String = ""

    public init(content: Binding<Content>) {
        self._content = content
    }

    var body: some View {
        ScrollView {
            BbMLView(displayBbML)
                .scenePadding(.horizontal)
        }
        .alert("Unable to load content", isPresented: $showLoadFailedMessage) {
            Button("Retry") {
                showLoadFailedMessage = false
                loadFailedMessage = ""

                Task {
                    try await learnKit
                        .refreshContent(
                            for: content.id,
                            includeChildren: true,
                            in: courseId!
                        )
                    await loadView(target: content)
                }
            }

            Button("Cancel") {
                showLoadFailedMessage = false
                loadFailedMessage = ""

                dismiss()
            }
        } message: {
            Text(loadFailedMessage)
        }
        .myBrightonBackground()
        .navigationTitle(content.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .userActivity(UserActivity.MyStudies.Content.view) {
            $0.title = "\(content.title) in {Module name}"
            // Spotlight
            // App Intents
            //$0.appEntityIdentifier = .init(for: T##Entity, identifier: T##Entity.ID)
        }
        .task {
            await loadView(target: content)
        }
    }

    private func loadView(target: Content) async {
        do {
            switch target.handler {
                case .contentItem:
                    guard let contentBody = target.body else {
                        loadFailedMessage = "The content is empty."
                        showLoadFailedMessage = true

                        return
                    }

                    bbML = try BbMLParser.default.parse(contentBody)
                    displayBbML = bbML

                    isLoading = false

                    break
                case .contentFolder(isBbPage: let isBbPage):
                    guard isBbPage else {
                        loadFailedMessage = "The content is not a BbML document."
                        showLoadFailedMessage = true

                        return
                    }

                    if let childContent = try await learnKit.getChildContent(for: target.id, in: courseId!).first {
                        await loadView(target: childContent)
                    } else {
                        let updatedContent = try await learnKit.refreshContent(
                            for: target.id,
                            in: courseId!
                        )
                        if updatedContent.isEmpty {
                            loadFailedMessage = "The content is empty."
                            showLoadFailedMessage = true
                            return
                        } else {
                            await loadView(target: content)
                        }
                    }

                    break
                default:
                    break
            }
        } catch {

        }
    }
}

#Preview(traits: .environmentObjects, .learnKit) {
    NavigationStack {
        ContentWrapperView(for: "0_0")
            .environment(\.courseId, "_0_1")
    }
}
