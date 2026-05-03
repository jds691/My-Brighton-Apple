//
//  SearchItemRowView.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/10/2025.
//

import SwiftUI
import CoreSpotlight
import LearnKit

struct SearchItemRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    private var csItem: CSSearchableItem

    init(item: CSSearchableItem) {
        self.csItem = item
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                image

                VStack(alignment: .leading) {
                    name
                    if let description = csItem.attributeSet.contentDescription {
                        Text(description)
                            .foregroundStyle(.brightonSecondary)
                            .lineLimit(3)
                    }
                    if let textContent = csItem.attributeSet.textContent {
                        Text(textContent)
                            .lineLimit(3)
                    }
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.brightonSecondary)
            }

            if let containerName = csItem.attributeSet.containerDisplayName {
                Divider()
                Label(containerName, systemImage: "graduationcap")
                    .lineLimit(1)
                    .font(.caption2)
                    .foregroundStyle(.brightonSecondary)
            }
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
        } else if let sfSymbolIconName = csItem.attributeSet.value(forCustomKey: LearnKitService.CoreSpotlightKeys.sfSymbolIconKey.csCustomAttributeKey) as? NSString {
            Image(systemName: String(sfSymbolIconName))
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
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

