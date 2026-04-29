//
//  ContentWrapperView.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import LearnKit

// TODO: Remove forced unwraps
struct ContentWrapperView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(\.learnKitService) private var learnKit
    @Environment(\.courseId) private var courseId

    private let contentId: Content.ID

    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String? = nil

    @State private var content: Content? = nil

    init(for contentIdentifier: Content.ID) {
        self.contentId = contentIdentifier
    }

    var body: some View {
        Group {
            if let content, let contentBinding = Binding<Content>($content) {
                switch content.handler {
                    case .contentItem:
                        BbMLContentViewer(content: contentBinding)
                    case .contentFolder(isBbPage: let isBbPage):
                        if isBbPage {
                            BbMLContentViewer(content: contentBinding)
                        } else {
                            ContentFolderView(content: contentBinding)
                        }
                    case .contentLesson:
                        ContentFolderView(content: contentBinding)
                    default:
                        errorView
                }
            } else {
                ProgressView()
                    .task {
                        do {
                            content = try await learnKit.getContent(for: contentId, in: courseId!)
                        } catch {
                            errorMessage = error.localizedDescription
                            showErrorMessage = true
                        }
                    }
                    .alert("Unable to load content", isPresented: $showErrorMessage) {
                        Button("OK") {
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
        }
    }

    @ViewBuilder
    private var errorView: some View {
        ProgressView()
    }
}
