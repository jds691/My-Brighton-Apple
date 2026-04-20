//
//  CachedGradebookAttempt.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/04/2026.
//

import Foundation
import SwiftData

@Model
class CachedGradebookAttempt {
    var id: GradebookAttempt.ID
    // TODO: Replace with something like User.ID
    var userId: String?
    var groupAttemptId: String?
    var groupOverride: Bool
    var status: Status
    var readyToPost: Bool
    var displayGrade: DisplayGrade?
    var score: Double?
    var feedback: String?
    var studentComments: String?
    var studentSubmission: String?
    var exempt: Bool
    var created: Date
    var attemptRecipt: EmbeddedAttemptReceipt?

    // Relational fields
    var associatedGradeColumn: CachedGradeColumn?

    init(from gradebookAttemptModel: GradebookAttempt) {
        self.id = gradebookAttemptModel.id
        self.userId = gradebookAttemptModel.userId
        self.groupAttemptId = gradebookAttemptModel.groupAttemptId
        self.groupOverride = gradebookAttemptModel.groupOverride
        self.status = Status(from: gradebookAttemptModel.status)
        self.readyToPost = gradebookAttemptModel.readyToPost
        self.displayGrade = gradebookAttemptModel.displayGrade
        self.score = gradebookAttemptModel.score
        self.feedback = gradebookAttemptModel.feedback
        self.studentComments = gradebookAttemptModel.studentComments
        self.studentSubmission = gradebookAttemptModel.studentSubmission
        self.exempt = gradebookAttemptModel.exempt
        self.created = gradebookAttemptModel.created
        self.attemptRecipt = gradebookAttemptModel.attemptRecipt

        // Relational fields, will be set by BbCache
        self.associatedGradeColumn = nil
    }

    func copyValues(from gradebookAttemptModel: GradebookAttempt) {
        self.id = gradebookAttemptModel.id
        self.userId = gradebookAttemptModel.userId
        self.groupAttemptId = gradebookAttemptModel.groupAttemptId
        self.groupOverride = gradebookAttemptModel.groupOverride
        self.status = Status(from: gradebookAttemptModel.status)
        self.readyToPost = gradebookAttemptModel.readyToPost
        self.displayGrade = gradebookAttemptModel.displayGrade
        self.score = gradebookAttemptModel.score
        self.feedback = gradebookAttemptModel.feedback
        self.studentComments = gradebookAttemptModel.studentComments
        self.studentSubmission = gradebookAttemptModel.studentSubmission
        self.exempt = gradebookAttemptModel.exempt
        self.created = gradebookAttemptModel.created
        self.attemptRecipt = gradebookAttemptModel.attemptRecipt
    }

    enum Status: String, Hashable, Codable {
        case notAttempted = "NotAttempted"
        case inProgress = "InProgress"
        case needsGrading = "NeedsGrading"
        case completed = "Completed"
        // Wtf are these names they chose lmao
        case inMoreProgress = "InMoreProgress"
        case needsMoreGrading = "NeedsMoreGrading"

        init(from gradebookAttemptStatusModel: GradebookAttempt.Status) {
            switch gradebookAttemptStatusModel {
                case .notAttempted:
                    self = .notAttempted
                case .inProgress:
                    self = .inProgress
                case .needsGrading:
                    self = .needsGrading
                case .completed:
                    self = .completed
                case .inMoreProgress:
                    self = .inMoreProgress
                case .needsMoreGrading:
                    self = .needsMoreGrading
            }
        }
    }
}
