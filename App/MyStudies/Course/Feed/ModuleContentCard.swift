//
//  ModuleContentCard.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import SwiftUI

struct ModuleContentCard: View {
    // TODO: Replace with a Content later
    var title: String
    var description: String
    var action: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "doc")
                    .resizable()
                    .scaledToFit()
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
        .contextMenu {
            downloadMenu
        }
    }

    @ViewBuilder
    private var metadata: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
        }
    }

    @ViewBuilder
    private var downloadMenu: some View {
        Menu {
            Section("Available Formats") {
                Button {

                } label: {
                    Text("HTML")
                    Text("For viewing in the browser and on mobile devices")
                }
                Button {

                } label: {
                    Text("ePub")
                    Text("For reading as an e-book on an iPad and other e-book readers")
                }
                Button {

                } label: {
                    Text("Electronic Braille")
                }
                Button {

                } label: {
                    Text("Audio")
                }
                Button {

                } label: {
                    Text("BeeLine Reader")
                }
                Button {

                } label: {
                    Text("Immersive Reader")

                }
                Button {

                } label: {
                    Text("Translated Version")
                }
            }
        } label: {
            Label("Download", systemImage: "arrow.down.circle")
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(.leading, 8)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ModuleContentCard(title: "Name", description: "Description") {

    }
}
