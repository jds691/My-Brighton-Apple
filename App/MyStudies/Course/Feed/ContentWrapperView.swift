//
//  ContentWrapperView.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import LearnKit

struct ContentWrapperView: View {
    @Environment(\.learnKitService) private var learnKit
    private let courseId: Course.ID
    private let contentId: Content.ID

    @State private var content: Content? = nil

    init(for contentIdentifier: Content.ID, courseId: Course.ID) {
        self.contentId = contentIdentifier
        self.courseId = courseId
    }

    var body: some View {
        Group {
            if let content, let contentBinding = Binding<Content>($content) {
                switch content.handler {
                    case .contentItem:
                        BbMLContentViewer(content: contentBinding, courseId: courseId)
                    case .contentFolder(isBbPage: let isBbPage):
                        if isBbPage {
                            BbMLContentViewer(content: contentBinding, courseId: courseId)
                        } else {
                            ContentFolderView(content: contentBinding, courseId: courseId)
                        }
                    default:
                        errorView
                }
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                content = try await learnKit.getContent(for: contentId, in: courseId)
            } catch {
                print(error)
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        ProgressView()
    }
}
