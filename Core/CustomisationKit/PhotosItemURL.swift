//
//  PhotosItemURL.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import CoreTransferable
internal import UniformTypeIdentifiers

struct PhotosItemURL: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { file in
            let fm = FileManager.default

            let customImageCache = fm.temporaryDirectory

            if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
                try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
            }

            let customImageFile = customImageCache.appending(path: UUID().uuidString, directoryHint: .notDirectory)

            try fm.copyItem(at: file.file, to: customImageFile)

            return Self(url: customImageFile)
        }
    }

    enum ImportError: Error {
        case appGroupSecurity
        case unknown
    }
}
