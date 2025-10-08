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
    let bbML: BbMLContent

    public init(_ bbML: BbMLContent) {
        self.bbML = bbML
    }

    public var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(bbML.chunks, id: \.self) { chunk in
                makeViewForChunk(chunk)
            }
        }
    }

    @ViewBuilder
    private func makeViewForChunk(_ chunk: BbMLContent.Chunk) -> some View {
        switch chunk {
            case .text(let string):
                Text(string)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .image(let url, let altDescription, let decorative):
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityValue(Text(altDescription ?? ""))
                        .accessibilityHidden(decorative)
                        .accessibilityShowsLargeContentViewer()
                } placeholder: {
                    ProgressView()
                }

            //case .document(let url):

            case .math(let mathML):
                MathMLView(mathML: mathML)
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
