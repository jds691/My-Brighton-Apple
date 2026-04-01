//
//  CustomisationService.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftData

public final class CustomisationService {
    // Also copied from LearnKit
    private let modelExecutor: any ModelExecutor
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }

    public init() {
        do {
            let schemaV1: Schema = .init([
                CourseCustomisation.self
            ])
            let config: ModelConfiguration = .init("Customisation", schema: schemaV1, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
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
