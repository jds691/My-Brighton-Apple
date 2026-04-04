//
//  CustomisationService.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftData
import PhotosUI
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

nonisolated
public final class CustomisationService {
    nonisolated(unsafe) public static var inMemoryOnly: Bool = false
    // Also copied from LearnKit
    private let modelExecutor: any ModelExecutor
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }

    nonisolated(unsafe) private static var _shared: CustomisationService? = nil
    public static var shared: CustomisationService {
        if let _shared {
            return _shared
        } else {
            _shared = CustomisationService()
            return _shared!
        }
    }

    private init() {
        do {
            let schemaV1: Schema = .init([
                CourseCustomisation.self,
                HomeCustomisation.self
            ])
            let config: ModelConfiguration = .init("Customisation", schema: schemaV1, isStoredInMemoryOnly: Self.inMemoryOnly, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

    // TODO: Caching
    public static func getBuiltInImageCollections() throws -> [ImageCollection] {
        guard let collectionsData = NSDataAsset(name: "Collections", bundle: .init(for: CustomisationService.self)) else { throw DecodingError.valueNotFound(NSDataAsset.self, .init(codingPath: [], debugDescription: "Sourced from CustomisationKit BuiltIn Images.xcasset")) }

        return try JSONDecoder().decode([ImageCollection].self, from: collectionsData.data)
    }

    public static func getAlwaysPresentImagePath() -> String {
        "safety"
    }

    public static func getBuiltInColours() -> [Color] {
        [
            .accent,
            .colibri1,
            .colibri2,
            .colibri3,
            .colibri4
        ]
    }

    public func getCourseCustomisation(for courseId: String) -> CourseCustomisation {
        do {
            var descriptor = FetchDescriptor<CourseCustomisation>(predicate: #Predicate { $0.courseId == courseId })
            descriptor.fetchLimit = 1

            if let result = try modelContext.fetch(descriptor).first {
                return result
            }

            let customisation = CourseCustomisation()
            customisation.courseId = courseId

            modelContext.insert(customisation)
            try modelContext.save()

            return customisation
        } catch {
            print(error)
            // TODO: Log error
            return CourseCustomisation()
        }
    }

    public func getHomeCustomisation() -> HomeCustomisation {
        do {
            var descriptor = FetchDescriptor<HomeCustomisation>()
            descriptor.fetchLimit = 1

            if let result = try modelContext.fetch(descriptor).first {
                return result
            }

            let customisation = HomeCustomisation()

            modelContext.insert(customisation)
            try modelContext.save()

            return customisation
        } catch {
            print(error)
            // TODO: Log error
            return HomeCustomisation()
        }
    }

    public static func storePhotosPickerBackgroundItem(_ item: PhotosPickerItem, for courseId: String) async throws -> URL {
        guard let url = try await item.loadTransferable(type: PhotosItemURL.self) else { throw PhotosItemURL.ImportError.unknown }

        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Course", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let customImageFile = customImageCache.appending(path: courseId, directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            return try fm.replaceItemAt(customImageFile, withItemAt: url.url, backupItemName: courseId + "_BAK") ?? customImageFile
        } else {
            try fm.copyItem(at: url.url, to: customImageFile)
        }

        return customImageFile
    }

    public static func storePhotosPickerBackgroundItem(_ item: PhotosPickerItem) async throws -> URL {
        guard let url = try await item.loadTransferable(type: PhotosItemURL.self) else { throw PhotosItemURL.ImportError.unknown }

        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Home", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let customImageFile = customImageCache.appending(path: "Background", directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            return try fm.replaceItemAt(customImageFile, withItemAt: url.url, backupItemName: "Background_BAK") ?? customImageFile
        } else {
            try fm.copyItem(at: url.url, to: customImageFile)
        }

        return customImageFile
    }
}
