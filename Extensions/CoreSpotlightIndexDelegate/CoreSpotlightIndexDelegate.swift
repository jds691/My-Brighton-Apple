//
//  CoreSpotlightIndexDelegate.swift
//  CoreSpotlightIndexDelegate
//
//  Created by Neo Salmon on 02/09/2025.
//

import CoreSpotlight
import LearnKit

class CoreSpotlightIndexDelegate: CSIndexExtensionRequestHandler {

    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            return try await LearnKitService(learnInstanceURL: Servers.Server1.url()).reindexAllContent()
        }

        semaphore.wait()
        acknowledgementHandler()
    }

    // WHAT DO YOU MEAN LOOKING UP THE ITEMS BY THEIR IDENTIFIERS IS 18.4+ ONLY
    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            return try await LearnKitService(learnInstanceURL: Servers.Server1.url()).reindexContent(withIdentifiers: identifiers)
        }

        semaphore.wait()
        acknowledgementHandler()
    }

    /*override func data(for searchableIndex: CSSearchableIndex, itemIdentifier: String, typeIdentifier: String) throws -> Data {
        return Data()
    }

    override func fileURL(for searchableIndex: CSSearchableIndex, itemIdentifier: String, typeIdentifier: String, inPlace: Bool) throws -> URL {
        return URL(fileURLWithPath: "")
    }*/
}
