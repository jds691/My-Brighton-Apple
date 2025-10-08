//
//  ModuleAnnouncementView.swift
//  My Brighton
//
//  Created by Neo Salmon on 09/08/2025.
//

import SwiftBbML
import SwiftUI

struct ModuleAnnouncementCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            BbMLView(
                BbMLContent(
                    header: .init(),
                    chunks: [
                        .text("Body text")
                    ]
                )
            )
            .lineLimit(3, reservesSpace: true)
            Divider()
            Text(verbatim: "Date and time")
                .lineLimit(1)
                .font(.caption2)
                .foregroundStyle(.brightonSecondary)
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
    private var header: some View {
        HStack(alignment: .center, spacing: 4) {
            //Image(systemName: "circle")
            Text("Announcement Title")
                .lineLimit(1)
                .font(.headline)
            Spacer()
            Button {

            } label: {
                Label("Mark as Read", systemImage: "xmark")
            }
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .foregroundStyle(.brightonSecondary)
            .imageScale(.large)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ModuleAnnouncementCard()
}
