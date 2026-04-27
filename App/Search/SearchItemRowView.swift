//
//  SearchItemRowView.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/10/2025.
//

import SwiftUI
import CoreSpotlight

struct SearchItemRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    private var csItem: CSSearchableItem

    init(item: CSSearchableItem) {
        self.csItem = item
    }

    var body: some View {
        HStack {
            image

            VStack(alignment: .leading) {
                name
                if let description = csItem.attributeSet.contentDescription {
                    Text(description)
                        .lineLimit(3)
                }
            }

            Spacer()

            Image(systemName: "chevron.forward")
                .foregroundStyle(.brightonSecondary)
        }
    }

    @ViewBuilder
    private var name: some View {
        if let displayName = csItem.attributeSet.displayName {
            Text(displayName)
                .bold()
                .lineLimit(3)
        } else if let title = csItem.attributeSet.title {
            Text(title)
                .bold()
                .lineLimit(3)
        } else {
            Text("No Title")
                .bold()
                .lineLimit(3)
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageData = csItem.attributeSet.thumbnailData {
            #if os(iOS)
            Image(uiImage: UIImage(data: imageData) ?? UIImage())
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: 45, height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
            #else
            Image(nsImage: NSImage(data: imageData) ?? NSImage())
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: 45, height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
            #endif
        } else if colorScheme == .dark, let darkImage = csItem.attributeSet.darkThumbnailURL {
            AsyncImage(url: darkImage) {
                $0
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
            } placeholder: {
                EmptyView()
            }
        } else if let lightImage = csItem.attributeSet.thumbnailURL {
            AsyncImage(url: lightImage) {
                $0
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
            } placeholder: {
                EmptyView()
            }
        }
    }
}

#Preview {
    let item = {
        let attributes = CSSearchableItemAttributeSet()
        attributes.title = "CI601"

        return CSSearchableItem(uniqueIdentifier: nil, domainIdentifier: nil, attributeSet: attributes)
    }()
    List {
        SearchItemRowView(item: item)
    }
}

