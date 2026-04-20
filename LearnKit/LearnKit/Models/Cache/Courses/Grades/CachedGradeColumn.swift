//
//  CachedGradeColumn.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/04/2026.
//


import Foundation
import SwiftData

@Model
class CachedGradeColumn {
    var id: GradeColumn.ID
    var externalId: String?
    var externalToolId: String?
    var name: String
    var displayName: String?
    var _description: String?
    var externalGrade: Bool
    var created: Date?
    var modified: Date?
    var possibleScore: Double
    var isAvailable: Bool
    var grading: CachedGradeColumn.Grading
    var gradebookCategoryId: String
    var formula: String?
    var includeInCalculations: Bool
    var showStatisticsToStudents: Bool
    var scoreProviderHandle: String
    var isSignature: Bool

    // Relational fields
    // Replaces the contentId field
    var relatedContent: CachedContent?
    var course: CachedCourse?
    @Relationship(inverse: \CachedGradebookAttempt.associatedGradeColumn)
    var attempts: [CachedGradebookAttempt] = []

    init(from gradeColumnModel: GradeColumn) {
        self.id = gradeColumnModel.id
        self.externalId = gradeColumnModel.externalId
        self.externalToolId = gradeColumnModel.externalToolId
        self.name = gradeColumnModel.name
        self.displayName = gradeColumnModel.displayName
        self._description = gradeColumnModel.description
        self.externalGrade = gradeColumnModel.externalGrade
        self.created = gradeColumnModel.created
        self.modified = gradeColumnModel.modified
        self.possibleScore = gradeColumnModel.possibleScore
        self.isAvailable = gradeColumnModel.isAvailable
        self.grading = Grading(from: gradeColumnModel.grading)
        self.gradebookCategoryId = gradeColumnModel.gradebookCategoryId
        self.formula = gradeColumnModel.formula
        self.includeInCalculations = gradeColumnModel.includeInCalculations
        self.showStatisticsToStudents = gradeColumnModel.showStatisticsToStudents
        self.scoreProviderHandle = gradeColumnModel.scoreProviderHandle
        self.isSignature = gradeColumnModel.isSignature

        // Relational fields, will be set by BbCache
        self.relatedContent = nil
        self.course = nil
    }

    func copyValues(from gradeColumnModel: GradeColumn) {
        self.id = gradeColumnModel.id
        self.externalId = gradeColumnModel.externalId
        self.externalToolId = gradeColumnModel.externalToolId
        self.name = gradeColumnModel.name
        self.displayName = gradeColumnModel.displayName
        self._description = gradeColumnModel.description
        self.externalGrade = gradeColumnModel.externalGrade
        self.created = gradeColumnModel.created
        self.modified = gradeColumnModel.modified
        self.possibleScore = gradeColumnModel.possibleScore
        self.isAvailable = gradeColumnModel.isAvailable
        self.grading = Grading(from: gradeColumnModel.grading)
        self.gradebookCategoryId = gradeColumnModel.gradebookCategoryId
        self.formula = gradeColumnModel.formula
        self.includeInCalculations = gradeColumnModel.includeInCalculations
        self.showStatisticsToStudents = gradeColumnModel.showStatisticsToStudents
        self.scoreProviderHandle = gradeColumnModel.scoreProviderHandle
        self.isSignature = gradeColumnModel.isSignature
    }

    public struct Grading: Hashable, Codable, Sendable {
        let dueDate: Date
        let attemptsAllowed: Int
        let scoringModel: Grading.ScoringModel
        let schemaId: String?
        let anonymousGradingType: Grading.AnonymousGrading

        init(from gradeColumnGradingModel: GradeColumn.Grading) {
            self.dueDate = gradeColumnGradingModel.dueDate
            self.attemptsAllowed = Int(gradeColumnGradingModel.attemptsAllowed)
            self.scoringModel = ScoringModel(from: gradeColumnGradingModel.scoringModel)
            self.schemaId = gradeColumnGradingModel.schemaId
            self.anonymousGradingType = AnonymousGrading(from: gradeColumnGradingModel.anonymousGradingType)
        }

        public enum AnonymousGrading: Hashable, Codable, Sendable {
            case none
            case afterAllGraded
            case date(_ releaseAfter: Date)

            init(from gradeColumnGradingAnonymousGradingModel: GradeColumn.Grading.AnonymousGrading) {
                switch gradeColumnGradingAnonymousGradingModel {
                    case .none:
                        self = .none
                    case .afterAllGraded:
                        self = .afterAllGraded
                    case .date(let releaseAfter):
                        self = .date(releaseAfter)
                }
            }
        }

        public enum ScoringModel: String, Hashable, Codable, Sendable {
            case last = "Last"
            case highest = "Highest"
            case lowest = "Lowest"
            case first = "First"
            case average = "Average"

            init(from gradeColumnGradingScoringModel: GradeColumn.Grading.ScoringModel) {
                switch gradeColumnGradingScoringModel {
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
        }
    }
}
