//
//  BbMLView.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/08/2025.
//

import SwiftBbML
import SwiftUI

// TODO: Ensure that BbMLView supports the lineLimit environment key
// https://github.com/users/jds691/projects/11/views/3?pane=issue&itemId=129421180

public struct BbMLView: View {
    private var chunks: [BbMLContent.Chunk]

    public init(_ bbML: BbMLContent) {
        self.chunks = []

        var currentString = AttributedString()
        for chunk in bbML {
            if case .text(let string) = chunk {
                if !currentString.characters.isEmpty {
                    currentString.append(AttributedString("\n"))
                }

                currentString.append(string)

            } else {
                if !currentString.characters.isEmpty {
                    chunks.append(.text(currentString))
                    currentString = AttributedString()
                }

                chunks.append(chunk)
            }
        }

        if !currentString.characters.isEmpty {
            print("currentString contents: \(String(describing: currentString))")
            chunks.append(.text(currentString))
        }
    }

    public var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(chunks, id: \.self) { chunk in
                makeViewForChunk(chunk)
            }
        }
    }

    @ViewBuilder
    private func makeViewForChunk(_ chunk: BbMLContent.Chunk) -> some View {
        switch chunk {
            case .text(let string):
                BbMLText(string)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            case .image(let url, let altDescription):
                if let url {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .accessibilityValue(Text(altDescription ?? ""))
                            .accessibilityShowsLargeContentViewer()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .accessibilityValue(Text(altDescription ?? ""))
                }

            case .document(let url, let attachmentInfo):
                BbMLAttachmentView(url: url, renderInfo: attachmentInfo)
            case .math(let math):
                if case .mathMl(let mathMl) = math {
                    MathMLView(mathML: mathMl)
                } else {
                    Text("Unable to render math.")
                        .onAppear {
                            assert(false)
                        }
                }


            //case .video(let url):

            default:
                Text("Unable to render content of an unknown type.")
        }
    }
}

#Preview {
    ScrollView {
        BbMLView(
            BbMLContent.exampleDocument
        )
        .scenePadding()
    }
}
