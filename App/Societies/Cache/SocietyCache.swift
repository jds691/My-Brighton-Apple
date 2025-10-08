//
//  SocietyCache.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/09/2025.
//

#if ENABLE_BSU
import Foundation
import SwiftData
import CoreSpotlight

#if os(iOS)
import UIKit
#else
import AppKit
#endif

// TODO: OH MY GOD CLEAN THIS UP _PLEASE_
// TODO: Change this to support partial societies e.g. just the display metadata

@ModelActor
actor SocietyCache {
    public init(inMemoryOnly: Bool = false) {
        let schema = Schema([
            SocietyModel.self
        ])
        do {
            self.init(modelContainer: try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemoryOnly)))
        } catch {
            fatalError()
        }
    }

    public func indexedSocietyCount() async -> Int {
        let descriptor = FetchDescriptor<SocietyModel>()

        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    public func setSocieties(societies: [Society]) async {
        do {
            try modelContainer.erase()
        } catch {

        }

        for society in societies {
            modelContext.insert(SocietyModel(from: society))
        }
        await indexSocieties(societies)
    }

    private func indexSocieties(_ societies: [Society]) async {
        let searchableIndex = CSSearchableIndex(name: "Societies")
        searchableIndex.beginBatch()

        var items: [CSSearchableItem] = []
        for society in societies {
            let attributeSet = CSSearchableItemAttributeSet()
            attributeSet.title = society.name
            //attributeSet.contentDescription = "Society"
            if let description = society.description {
                attributeSet.contentDescription = description
            }

            do {
                if let logoURL = society.logoURL {
                    attributeSet.thumbnailData = try await URLSession.shared.data(from: logoURL).0
                } else {
                    #if os(iOS)
                    attributeSet.thumbnailData = await UIImage(resource: .societyLogoPlaceholder).heicData()
                    #else
                    attributeSet.thumbnailData = await NSImage(resource: .societyLogoPlaceholder).tiffRepresentation
                    #endif
                }
            } catch {

            }

            let item = CSSearchableItem(uniqueIdentifier: "society/\(society.id)", domainIdentifier: "Societies", attributeSet: attributeSet)
            await item.associateAppEntity(SocietyEntity(from: society))

            items.append(item)
        }

        do {
            try await searchableIndex.indexSearchableItems(items)

            try await searchableIndex.endBatch(withClientState: Data())
        } catch {

        }
    }
}
#endif
