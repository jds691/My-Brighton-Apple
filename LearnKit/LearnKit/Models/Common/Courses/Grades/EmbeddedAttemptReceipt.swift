//
//  EmbeddedAttemptReceipt.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/04/2026.
//

import Foundation

public struct EmbeddedAttemptReceipt: Hashable, Codable, Sendable {
    public let receiptId: String
    public let submissionDate: Date
    public let submissionTotalSize: Int64?
    public let courseId: Course.ID?
    public let gradableItemId: String?
    public let attemptId: String?
    public let userId: String?
    public let groupAttemptId: String?
    public let groupId: String?
    public let responseStatus: ResponseStatus?
    public let submissionType: SubmissionType?

    init?(from embeddedAttemptReciptSchema: Components.Schemas.EmbeddedAttemptReceipt) {
        guard
            let receiptId = embeddedAttemptReciptSchema.receiptId,
            let submissionDate = embeddedAttemptReciptSchema.submissionDate
        else {
            return nil
        }

        self.receiptId = receiptId
        self.submissionDate = submissionDate
        self.submissionTotalSize = embeddedAttemptReciptSchema.submissionTotalSize
        self.courseId = embeddedAttemptReciptSchema.courseId
        self.gradableItemId = embeddedAttemptReciptSchema.gradableItemId
        self.attemptId = embeddedAttemptReciptSchema.attemptId
        self.userId = embeddedAttemptReciptSchema.userId
        self.groupAttemptId = embeddedAttemptReciptSchema.groupAttemptId
        self.groupId = embeddedAttemptReciptSchema.groupId

        if let responsePayload = embeddedAttemptReciptSchema.responseStatus {
            self.responseStatus = ResponseStatus(from: responsePayload)
        } else {
            self.responseStatus = nil
        }

        if let submissionTypePayload = embeddedAttemptReciptSchema.submissionType {
            self.submissionType = SubmissionType(from: submissionTypePayload)
        } else {
            self.submissionType = nil
        }
    }

    public enum ResponseStatus: String, Hashable, Codable, Sendable {
        case receiptAndAttemptExist = "ReceiptAndAttemptExist"
        case receiptExistsButAttemptDoesNot = "ReceiptExistsButAttemptDoesNot"
        case receiptExistsNoAccessToAttempt = "ReceiptExistsNoAccessToAttempt"
        case receiptExistsColumnSoftDeleted = "ReceiptExistsColumnSoftDeleted"

        init(from embeddedAttemptReciptResponseStatusSchema: Components.Schemas.EmbeddedAttemptReceipt.ResponseStatusPayload) {
            switch embeddedAttemptReciptResponseStatusSchema {
                case .receiptAndAttemptExist:
                    self = .receiptAndAttemptExist
                case .receiptExistsButAttemptDoesNot:
                    self = .receiptExistsButAttemptDoesNot
                case .receiptExistsNoAccessToAttempt:
                    self = .receiptExistsNoAccessToAttempt
                case .receiptExistsColumnSoftDeleted:
                    self = .receiptExistsColumnSoftDeleted
            }
        }
    }

    public enum SubmissionType: String, Hashable, Codable, Sendable {
        case manuallySubmitted = "ManuallySubmitted"
        case automaticallySubmittedByBrowser = "AutomaticallySubmittedByBrowser"
        case automaticallySubmittedByServer = "AutomaticallySubmittedByServer"
        case unknown = "Unknown"

        init(from embeddedAttemptReciptSubmissionTypeSchema: Components.Schemas.EmbeddedAttemptReceipt.SubmissionTypePayload) {
            switch embeddedAttemptReciptSubmissionTypeSchema {
                case .manuallySubmitted:
                    self = .manuallySubmitted
                case .automaticallySubmittedByBrowser:
                    self = .automaticallySubmittedByBrowser
                case .automaticallySubmittedByServer:
                    self = .automaticallySubmittedByServer
                case .unknown:
                    self = .unknown
            }
        }
    }
}
