//
//  ContentListCard.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import LearnKit
import CoreDesign
import UniformTypeIdentifiers

struct ContentListCard: View {
    private var content: Content

    init(for content: Content) {
        self.content = content
    }

    var body: some View {
        HStack(spacing: 8) {
            icon
                .frame(width: 24, height: 24)
            metadata
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .contraCard()
    }

    @ViewBuilder
    private var icon: some View {
        switch content.handler {
            case .contentItem:
                Image(systemName: "richtext.page")
                    .resizable()
                    .scaledToFit()
            case .contentLesson:
                Image(systemName: "graduationcap")
                    .resizable()
                    .scaledToFit()
            case .contentFolder(isBbPage: let isBbPage):
                Image(systemName: isBbPage ? "richtext.page" : "folder")
                    .resizable()
                    .scaledToFit()
            case .assignment(gradeColumn: _, isGroup: _):
                Image(systemName: "questionmark.text.page")
                    .resizable()
                    .scaledToFit()
            case .testLink(target: _, gradeColumn: _):
                Image(systemName: "questionmark.text.page")
                    .resizable()
                    .scaledToFit()
            case .externalLink(_):
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
            case .ltiLink(_, parameters: _):
                Image(systemName: "globe.desk")
                    .resizable()
                    .scaledToFit()
            case .contentFile(uploadId: _, fileName: _, mimeType: let mimeType, duplicateFileHandling: _):
                if let utType = UTType(mimeType: mimeType) {
                    switch utType {
                        case .image:
                            Image(systemName: "questionmark")
                                .resizable()
                                .scaledToFit()
                        case .pdf:
                            Image(systemName: "append.page")
                                .resizable()
                                .scaledToFit()
                        case .presentation:
                            Image(systemName: "rectangle.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                        default:
                            Image(systemName: "questionmark")
                                .resizable()
                                .scaledToFit()
                    }
                } else {
                    Image(systemName: "questionmark")
                        .resizable()
                        .scaledToFit()
                }
            default:
                Image(systemName: "questionmark")
                    .resizable()
                    .scaledToFit()
        }
    }

    @ViewBuilder
    private var metadata: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(content.title)
                .font(.headline)

            if let description = content.description {
                Text(description)
            }
        }
    }
}
