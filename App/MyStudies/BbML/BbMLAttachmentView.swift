//
//  BbMLAttachmentView.swift
//  My Brighton
//
//  Created by Neo Salmon on 06/11/2025.
//

import SwiftBbML
import SwiftUI
import QuickLookThumbnailing

struct BbMLAttachmentView: View {
    // TEMP
    @Environment(\.openURL) private var openURL

    private let url: URL
    private let renderInfo: BbFileAttachment

    init(url: URL, renderInfo: BbFileAttachment) {
        self.url = url
        self.renderInfo = renderInfo
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "doc")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(renderInfo.name)
                    .bold()
            }
            Spacer()

            /*Image(systemName: "circle")
                .imageScale(.large)*/
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.brightonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .strokeBorder(lineWidth: 3, antialiased: true)
        }
        // TEMP
        .onTapGesture {
            openURL(url)
        }
    }
}
