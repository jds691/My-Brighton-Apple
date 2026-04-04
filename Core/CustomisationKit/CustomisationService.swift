//
//  CustomisationService.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftData
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
                CourseCustomisation.self
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

            return customisation
        } catch {
            // TODO: Log error
            return CourseCustomisation()
        }
    }
}
