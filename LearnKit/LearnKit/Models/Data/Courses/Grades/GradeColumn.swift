//
//  GradeColumn.swift
//  LearnKit
//
//  Created by Neo Salmon on 17/04/2026.
//

import Foundation
import os

/*
 (V2 API)
 Default fields when requesting grade columns are:
 - id
 - name
 - contentId (still optional)
 - score
 - availability
 - grading
 - gradebookcategoryid
 - includeincalculation
 - scoreProviderHandle
 - learningOutcome
 */

// This one deviates quite a bit from the real API

public struct GradeColumn: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "GradeColumn")

    public let id: String
    public let externalId: String?
    public let externalToolId: String?
    public let name: String
    public let displayName: String?
    public let description: String?
    public let externalGrade: Bool
    public let created: Date?
    public let modified: Date?
    public let contentId: String?
    // Mapped to score field
    public let possibleScore: Double
    // The availability enum is only Yes or No i.e. Bool
    public let isAvailable: Bool
    public let grading: GradeColumn.Grading
    public let gradebookCategoryId: String
    public let formula: String?
    public let includeInCalculations: Bool
    public let showStatisticsToStudents: Bool
    public let scoreProviderHandle: String
    public let isSignature: Bool

    init?(from gradeColumnSchema: Components.Schemas.GradeColumn) {
        guard
            // Grade Column Fields
            let id = gradeColumnSchema.id,
            let name = gradeColumnSchema.name,
            let possibleScore = gradeColumnSchema.score?.possible,
            let grading = gradeColumnSchema.grading,
            let gradebookCategoryId = gradeColumnSchema.gradebookCategoryId,
            let scoreProviderHandle = gradeColumnSchema.scoreProviderHandle,

                // Required Data Models
            let gradingModel = Grading(from: grading)
        else {
            Self.logger.error("gradeColumnSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
            dump(gradeColumnSchema)
#endif

            return nil
        }

        self.id = id
        self.externalId = gradeColumnSchema.externalId
        self.externalToolId = gradeColumnSchema.externalToolId
        self.name = name
        self.displayName = gradeColumnSchema.displayName
        self.description = gradeColumnSchema.description
        self.externalGrade = gradeColumnSchema.externalGrade ?? false
        self.created = gradeColumnSchema.created
        self.modified = gradeColumnSchema.modified
        self.contentId = gradeColumnSchema.contentId
        self.possibleScore = possibleScore
        self.isAvailable = gradeColumnSchema.availability?.available == .yes
        self.grading = gradingModel
        self.gradebookCategoryId = gradebookCategoryId
        self.formula = gradeColumnSchema.formula?.formula
        self.includeInCalculations = gradeColumnSchema.includeInCalculations ?? false
        self.showStatisticsToStudents = gradeColumnSchema.showStatisticsToStudents ?? false
        self.scoreProviderHandle = scoreProviderHandle
        self.isSignature = gradeColumnSchema.learningOutcome?.signature ?? false
    }

    init(from cachedGradeColumn: CachedGradeColumn) {
        self.id = cachedGradeColumn.id
        self.externalId = cachedGradeColumn.externalId
        self.externalToolId = cachedGradeColumn.externalToolId
        self.name = cachedGradeColumn.name
        self.displayName = cachedGradeColumn.displayName
        self.description = cachedGradeColumn._description
        self.externalGrade = cachedGradeColumn.externalGrade
        self.created = cachedGradeColumn.created
        self.modified = cachedGradeColumn.modified
        self.contentId = cachedGradeColumn.relatedContent?.id
        self.possibleScore = cachedGradeColumn.possibleScore
        self.isAvailable = cachedGradeColumn.isAvailable
        self.grading = Grading(from: cachedGradeColumn.grading)
        self.gradebookCategoryId = cachedGradeColumn.gradebookCategoryId
        self.formula = cachedGradeColumn.formula
        self.includeInCalculations = cachedGradeColumn.includeInCalculations
        self.showStatisticsToStudents = cachedGradeColumn.showStatisticsToStudents
        self.scoreProviderHandle = cachedGradeColumn.scoreProviderHandle
        self.isSignature = cachedGradeColumn.isSignature
    }

    public struct Grading: Hashable, Sendable {
        public let dueDate: Date
        public let attemptsAllowed: Int
        public let scoringModel: Grading.ScoringModel
        public let schemaId: String?
        public let anonymousGradingType: Grading.AnonymousGrading

        init?(from gradeColumnGradingSchema: Components.Schemas.GradeColumn.GradingPayload) {
            guard
                // Grade Column Grading Fields
                let dueDate = gradeColumnGradingSchema.due,
                let attemptsAllowed = gradeColumnGradingSchema.attemptsAllowed,
                let scoringModelSchema = gradeColumnGradingSchema.scoringModel,
                let anonymousGradingSchema = gradeColumnGradingSchema.anonymousGrading,

                let anonymousGradingModel = Grading.AnonymousGrading(from: anonymousGradingSchema)
            else {
                GradeColumn.logger.error("gradeColumnGradingSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                dump(gradeColumnGradingSchema)
#endif

                return nil
            }

            self.dueDate = dueDate
            self.attemptsAllowed = Int(attemptsAllowed)
            self.scoringModel = ScoringModel(from: scoringModelSchema)
            self.schemaId = gradeColumnGradingSchema.schemaId
            self.anonymousGradingType = anonymousGradingModel
        }

        init(from cachedGradeColumnGrading: CachedGradeColumn.Grading) {
            self.dueDate = cachedGradeColumnGrading.dueDate
            self.attemptsAllowed = cachedGradeColumnGrading.attemptsAllowed
            self.scoringModel = ScoringModel(from: cachedGradeColumnGrading.scoringModel)
            self.schemaId = cachedGradeColumnGrading.schemaId
            self.anonymousGradingType = AnonymousGrading(from: cachedGradeColumnGrading.anonymousGradingType)
        }

        public enum AnonymousGrading: Hashable, Sendable {
            case none
            case afterAllGraded
            case date(_ releaseAfter: Date)

            init?(from gradeColumnGradingAnonymousGradingSchema: Components.Schemas.GradeColumn.GradingPayload.AnonymousGradingPayload) {
                guard let gradingType = gradeColumnGradingAnonymousGradingSchema._type else {
                    GradeColumn.logger.error("gradeColumnGradingAnonymousGradingSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
                    dump(gradeColumnGradingAnonymousGradingSchema)
#endif

                    return nil
                }

                switch gradingType {
                    case .none:
                        self = .none
                    case .afterAllGraded:
                        self = .afterAllGraded
                    case .date:
                        guard
                            let releaseAfter = gradeColumnGradingAnonymousGradingSchema.releaseAfter
                        else {
                            GradeColumn.logger.error("gradeColumnGradingAnonymousGradingSchema is Date but is missing `releaseAfter` field, unable to construt data model.")
#if DEBUG
                            dump(gradeColumnGradingAnonymousGradingSchema)
#endif

                            return nil
                        }

                        self = .date(releaseAfter)
                }
            }

            init(from cachedGradeColumnGradingAnonymousGrading: CachedGradeColumn.Grading.AnonymousGrading) {
                switch cachedGradeColumnGradingAnonymousGrading {
                    case .none:
                        self = .none
                    case .afterAllGraded:
                        self = .afterAllGraded
                    case .date(let releaseAfter):
                        self = .date(releaseAfter)
                }
            }
        }

        public enum ScoringModel: Hashable, Sendable {
            case last
            case highest
            case lowest
            case first
            case average

            init(from gradeColumnGradingScoringModelSchema: Components.Schemas.GradeColumn.GradingPayload.ScoringModelPayload) {
                switch gradeColumnGradingScoringModelSchema {
                    case .last:
                        self = .last
                    case .highest:
                        self = .highest
                    case .lowest:
                        self = .lowest
                    case .first:
                        self = .first
                    case .average:
                        self = .average
                }
            }

            init(from cachedGradeColumnGradingScoring: CachedGradeColumn.Grading.ScoringModel) {
                switch cachedGradeColumnGradingScoring {
                    case .last:
                        self = .last
                    case .highest:
                        self = .highest
                    case .lowest:
                        self = .highest
                    case .first:
                        self = .first
                    case .average:
                        self = .average
                }
            }
        }
    }
}
