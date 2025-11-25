//
//  ContentListCard.swift
//  My Brighton
//
//  Created by Neo Salmon on 25/11/2025.
//

import SwiftUI
import LearnKit

struct ContentListCard: View {
    private var content: Content

    init(for content: Content) {
        self.content = content
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                icon
                    .frame(width: 24, height: 24)
                metadata
            }
            Spacer()

            Image(systemName: "circle")
                .imageScale(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.brightonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .strokeBorder(lineWidth: 3, antialiased: true)
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch content.handler {
            case .contentItem:
                Image(systemName: "richtext.page")
                    .resizable()
                    .scaledToFit()
            case .contentFolder(isBbPage: let isBbPage):
                Image(systemName: isBbPage ? "richtext.page" : "folder")
                    .resizable()
                    .scaledToFit()
            default:
                Image(systemName: "doc")
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
