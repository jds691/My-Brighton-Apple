//
//  GradebookAttempt.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/04/2026.
//

import Foundation
import os

/**
 - id
 - userId
 - status
 - exempt
 - created
 */

// Fields that the docs said would be excluded have also been excluded from the model
// With the exception of fields that were returned by prodding the API using the console
// This only affects the score field being included

public struct GradebookAttempt: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "GradebookAttempt")

    public let id: String
    // TODO: Replace with something like User.ID
    public let userId: String?
    public let groupAttemptId: String?
    public let groupOverride: Bool
    public let status: Status
    public let readyToPost: Bool
    public let displayGrade: DisplayGrade?
    //public let text: String?
    public let score: Double?
    //public let reconcilliationMode: ReconciliationMode?
    //public let notes: String?
    public let feedback: String?
    public let studentComments: String?
    public let studentSubmission: String?
    public let exempt: Bool
    public let created: Date
    //public let attemptDate: Date?
    //public let modified: Date?
    public let attemptRecipt: EmbeddedAttemptReceipt?

    init?(from gradebookAttemptSchema: Components.Schemas.GradebookAttempt) {
        guard
            // Grade Column Fields
            let id = gradebookAttemptSchema.id,
            let status = gradebookAttemptSchema.status,
            let exempt = gradebookAttemptSchema.exempt,
            let created = gradebookAttemptSchema.created
        else {
            Self.logger.error("gradebookAttemptSchema is missing minimum required fields, unable to construt data model.")
#if DEBUG
            dump(gradebookAttemptSchema)
#endif

            return nil
        }

        self.id = id
        self.userId = gradebookAttemptSchema.userId
        self.groupAttemptId = gradebookAttemptSchema.groupAttemptId
        self.groupOverride = gradebookAttemptSchema.groupOverride ?? false
        self.status = Status(from: status)
        self.readyToPost = gradebookAttemptSchema.readyToPost ?? false
        if let displayGradePayload = gradebookAttemptSchema.displayGrade {
            self.displayGrade = DisplayGrade(from: displayGradePayload)
        } else {
            self.displayGrade = nil
        }
        self.score = gradebookAttemptSchema.score
        self.feedback = gradebookAttemptSchema.feedback
        self.studentComments = gradebookAttemptSchema.studentComments
        self.studentSubmission = gradebookAttemptSchema.studentSubmission
        self.exempt = exempt
        self.created = created
        if let attemptReciptPayload = gradebookAttemptSchema.attemptReceipt {
            self.attemptRecipt = EmbeddedAttemptReceipt(from: attemptReciptPayload)
        } else {
            self.attemptRecipt = nil
        }
    }

    public enum Status: Hashable, Sendable {
        case notAttempted
        case inProgress
        case needsGrading
        case completed
        // Wtf are these names they chose lmao
        case inMoreProgress
        case needsMoreGrading

        init(from gradebookAttemptStatusSchema: Components.Schemas.GradebookAttempt.StatusPayload) {
            switch gradebookAttemptStatusSchema {
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

