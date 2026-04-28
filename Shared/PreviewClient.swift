//
//  PreviewClient.swift
//  My Brighton
//
//  Created by Neo Salmon on 13/10/2025.
//

import Foundation
import LearnKit
internal import OpenAPIRuntime

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct PreviewClient: APIProtocol {
    static let decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601

        return jsonDecoder
    }()
    let systemAnnouncements: [Components.Schemas.SystemAnnouncement] = []

    let courses: [Components.Schemas.Course] = try! decoder.decode([Components.Schemas.Course].self, from: NSDataAsset(name: "Preview Data/Courses")!.data)

    let terms: [Components.Schemas.Term] = try! decoder.decode([Components.Schemas.Term].self, from: NSDataAsset(name: "Preview Data/Terms")!.data)

    let courseContents: Dictionary<String, [Components.Schemas.Content]> = [
        "_130430_1": try! decoder.decode([Components.Schemas.Content].self, from: NSDataAsset(name: "Preview Data/Contents/_130430_1")!.data),
        "_130431_1": try! decoder.decode([Components.Schemas.Content].self, from: NSDataAsset(name: "Preview Data/Contents/_130431_1")!.data),
        "_130442_1": try! decoder.decode([Components.Schemas.Content].self, from: NSDataAsset(name: "Preview Data/Contents/_130442_1")!.data),
        "_130438_1": try! decoder.decode([Components.Schemas.Content].self, from: NSDataAsset(name: "Preview Data/Contents/_130438_1")!.data),
        "_130441_1": try! decoder.decode([Components.Schemas.Content].self, from: NSDataAsset(name: "Preview Data/Contents/_130441_1")!.data)
    ]

    let courseAnnouncements: Dictionary<String, [Components.Schemas.CourseAnnouncement]> = [
        "_130430_1": try! decoder.decode([Components.Schemas.CourseAnnouncement].self, from: NSDataAsset(name: "Preview Data/Announcements/_130430_1")!.data),
        "_130431_1": try! decoder.decode([Components.Schemas.CourseAnnouncement].self, from: NSDataAsset(name: "Preview Data/Announcements/_130431_1")!.data),
        "_130442_1": try! decoder.decode([Components.Schemas.CourseAnnouncement].self, from: NSDataAsset(name: "Preview Data/Announcements/_130442_1")!.data),
        "_130438_1": try! decoder.decode([Components.Schemas.CourseAnnouncement].self, from: NSDataAsset(name: "Preview Data/Announcements/_130438_1")!.data),
        "_130441_1": try! decoder.decode([Components.Schemas.CourseAnnouncement].self, from: NSDataAsset(name: "Preview Data/Announcements/_130441_1")!.data)
    ]

    let gradebookColumns: [String: [Components.Schemas.GradeColumn]] = [
        "_130430_1": try! decoder.decode([Components.Schemas.GradeColumn].self, from: NSDataAsset(name: "Preview Data/GradeColumns/_130430_1")!.data),
        "_130431_1": try! decoder.decode([Components.Schemas.GradeColumn].self, from: NSDataAsset(name: "Preview Data/GradeColumns/_130431_1")!.data),
        "_130442_1": try! decoder.decode([Components.Schemas.GradeColumn].self, from: NSDataAsset(name: "Preview Data/GradeColumns/_130442_1")!.data),
        "_130438_1": try! decoder.decode([Components.Schemas.GradeColumn].self, from: NSDataAsset(name: "Preview Data/GradeColumns/_130438_1")!.data),
        "_130441_1": try! decoder.decode([Components.Schemas.GradeColumn].self, from: NSDataAsset(name: "Preview Data/GradeColumns/_130441_1")!.data)
    ]

    let gradebookColumnAttempts: [String: [String: [Components.Schemas.GradebookAttempt]]] = [
        "_130430_1": [
            "_747860_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_747860_1")!.data),
            "_747864_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_747864_1")!.data),
            "_747865_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_747865_1")!.data),
            "_751801_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_751801_1")!.data),
            "_751804_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_751804_1")!.data)
        ],
        "_130431_1": [:],
        "_130438_1": [
            "_751858_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_751858_1")!.data),
            "_751860_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_751860_1")!.data),
            "_762321_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_762321_1")!.data),
            "_762322_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_762322_1")!.data)
        ],
        "_130441_1": [
            "_758433_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_758433_1")!.data),
            "_758434_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_758434_1")!.data),
            "_758436_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_758436_1")!.data),
            "_758437_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_758437_1")!.data),
            "_763414_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_763414_1")!.data),
            "_763415_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_763415_1")!.data)
        ],
        "_130442_1": [
            "_759273_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_759273_1")!.data),
            "_759276_1": try! decoder.decode([Components.Schemas.GradebookAttempt].self, from: NSDataAsset(name: "Preview Data/GradeColumns/Attempts/_759276_1")!.data)
        ],
    ]

    func getV1Announcements(_ input: LearnKit.Operations.GetV1Announcements.Input) async throws -> LearnKit.Operations.GetV1Announcements.Output {
        return .ok(.init(body: .json(.init(results: systemAnnouncements))))
    }

    func getV1AnnouncementsAnnouncementId(_ input: LearnKit.Operations.GetV1AnnouncementsAnnouncementId.Input) async throws -> LearnKit.Operations.GetV1AnnouncementsAnnouncementId.Output {
        if systemAnnouncements.contains(where: { $0.id == input.path.announcementId }) {
            return .ok(.init(body: .json(systemAnnouncements.first(where: { $0.id == input.path.announcementId })!)))
        } else {
            return .notFound(.init(body: .json(.init(message: "Announcement for id could not be found."))))
        }
    }

    func getV1TermsTermId(_ input: LearnKit.Operations.GetV1TermsTermId.Input) async throws -> LearnKit.Operations.GetV1TermsTermId.Output {
        if terms.contains(where: { $0.id == input.path.termId }) {
            return .ok(.init(body: .json(terms.first(where: { $0.id == input.path.termId })!)))
        } else {
            return .notFound(.init(body: .json(.init(status: "Idk", code: "Idk", message: "Term not found for id", developerMessage: nil, extraInfo: nil))))
        }
    }

    func getV1Terms(_ input: LearnKit.Operations.GetV1Terms.Input) async throws -> LearnKit.Operations.GetV1Terms.Output {
        return .ok(.init(body: .json(.init(results: terms))))
    }

    func getV3CoursesCourseId(_ input: LearnKit.Operations.GetV3CoursesCourseId.Input) async throws -> LearnKit.Operations.GetV3CoursesCourseId.Output {
        if courses.contains(where: { $0.id == input.path.courseId }) {
            return .ok(.init(body: .json(courses.first(where: { $0.id == input.path.courseId })!)))
        } else {
            return .notFound(.init(body: .json(.init(status: "Idk", code: "Idk", message: "Term not found for id", developerMessage: nil, extraInfo: nil))))
        }
    }

    func getV3Courses(_ input: LearnKit.Operations.GetV3Courses.Input) async throws -> LearnKit.Operations.GetV3Courses.Output {
        return .ok(.init(body: .json(.init(results: courses))))
    }

    func getV1CoursesCourseIdContents(_ input: LearnKit.Operations.GetV1CoursesCourseIdContents.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContents.Output {
        if !courseContents.keys.contains(input.path.courseId) {
            return .forbidden(.init(body: .json(.init(status: "Idk", code: nil, message: "User not enrolled in course", developerMessage: nil, extraInfo: nil))))
        }

        return .ok(.init(body: .json(.init(results: courseContents[input.path.courseId]!.filter({ $0.parentId == "0" })))))
    }

    func getV1CoursesCourseIdContentsContentId(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentId.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentId.Output {
        if !courseContents.keys.contains(input.path.courseId) {
            return .undocumented(statusCode: 404, .init())
        }

        // Special cases
        let identifier: String?
        if input.path.contentId == "ROOT" {
            identifier = courseContents[input.path.courseId]!.filter({ $0.parentId == nil }).first!.id
            //return .ok(.init(body: .json()))
        } else {
            identifier = input.path.contentId
        }

        if !(courseContents[input.path.courseId]?.contains(where: { $0.id == identifier }) ?? false) {
            return .undocumented(statusCode: 404, .init())
        }

        return .ok(.init(body: .json(courseContents[input.path.courseId]!.first(where: { $0.id == identifier })!)))
    }

    func getV1CoursesCourseIdContentsContentIdChildren(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdChildren.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdChildren.Output {
        if !courseContents.keys.contains(input.path.courseId) {
            return .undocumented(statusCode: 404, .init())
        }

        // Special cases
        let identifier: String?
        if input.path.contentId == "ROOT" {
            identifier = courseContents[input.path.courseId]!.filter({ $0.parentId == nil }).first!.id
            //return .ok(.init(body: .json()))
        } else {
            identifier = input.path.contentId
        }

        if !(courseContents[input.path.courseId]?.contains(where: { $0.id == identifier }) ?? false) {
            return .undocumented(statusCode: 404, .init())
        }

        let content = courseContents[input.path.courseId]!.first(where: { $0.id == identifier })!

        if !(content.hasChildren ?? false) {
            return .ok(.init(body: .json(.init(results: []))))
        }

        return .ok(.init(body: .json(.init(results: courseContents[input.path.courseId]!.filter({ $0.parentId == identifier })))))
    }

    func getV1CoursesCourseIdAnnouncementsAnnouncementId(_ input: LearnKit.Operations.GetV1CoursesCourseIdAnnouncementsAnnouncementId.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdAnnouncementsAnnouncementId.Output {
        if let announcements = courseAnnouncements[input.path.courseId] {
            if let announcement = announcements.first(where: { $0.id == input.path.announcementId }) {
                return .ok(.init(body: .json(announcement)))
            } else {
                return .notFound(.init(body: .json(.init(message: "Unable to find course announcement for id"))))
            }
        } else {
            return .forbidden(.init(body: .json(.init(message: "User does not have access to course"))))
        }
    }

    func getV1CoursesCourseIdAnnouncements(_ input: LearnKit.Operations.GetV1CoursesCourseIdAnnouncements.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdAnnouncements.Output {
        if let announcements = courseAnnouncements[input.path.courseId] {
            return .ok(.init(body: .json(.init(results: announcements))))
        } else {
            return .forbidden(.init(body: .json(.init(message: "User does not have access to course"))))
        }
    }

    func getV2CoursesCourseIdGradebookColumns(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumns.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumns.Output {
        if let columns = gradebookColumns[input.path.courseId] {
            return .ok(.init(body: .json(.init(results: columns))))
        } else {
            return .forbidden(.init(body: .json(.init(message: "User does not have access to course"))))
        }
    }

    func getV2CoursesCourseIdGradebookColumnsColumnId(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnId.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnId.Output {
        if let columns = gradebookColumns[input.path.courseId] {
            if let column = columns.first(where: { $0.id == input.path.columnId }) {
                return .ok(.init(body: .json(column)))
            } else {
                return .notFound(.init(body: .json(.init(message: "Unable to find gradebook column for id"))))
            }
        } else {
            return .forbidden(.init(body: .json(.init(message: "User does not have access to course"))))
        }
    }

    func getV2CoursesCourseIdGradebookColumnsColumnIdAttempts(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttempts.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttempts.Output {
        if let attempts = gradebookColumnAttempts[input.path.courseId]?[input.path.columnId] {
            return .ok(.init(body: .json(.init(results: attempts))))
        } else {
            return .forbidden(.init(body: .json(.init(message: "User does not have access to course"))))
        }
    }

    func getV2CoursesCourseIdGradebookColumnsColumnIdAttemptsAttemptId(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttemptsAttemptId.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttemptsAttemptId.Output {
        if let attempts = gradebookColumnAttempts[input.path.courseId]?[input.path.columnId] {
            if let attempt = attempts.first(where: { $0.id == input.path.attemptId }) {
                return .ok(.init(body: .json(attempt)))
            } else {
                return .notFound(.init(body: .json(.init(message: "Unable to find gradebook attempt for id"))))
            }
        } else {
            return .forbidden(.init(body: .json(.init(message: "User does not have access to course"))))
        }
    }

    func deleteV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId(_ input: LearnKit.Operations.DeleteV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId.Input) async throws -> LearnKit.Operations.DeleteV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId.Output {
        fatalError()
    }

    func patchV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId(_ input: LearnKit.Operations.PatchV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId.Input) async throws -> LearnKit.Operations.PatchV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId.Output {
        fatalError()
    }

    func getV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteriaCriterionId.Output {
        fatalError()
    }

    func postV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteria(_ input: LearnKit.Operations.PostV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteria.Input) async throws -> LearnKit.Operations.PostV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteria.Output {
        fatalError()
    }

    func getV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteria(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteria.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleIdCriteria.Output {
        fatalError()
    }

    func deleteV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId(_ input: LearnKit.Operations.DeleteV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Input) async throws -> LearnKit.Operations.DeleteV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Output {
        fatalError()
    }

    func patchV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId(_ input: LearnKit.Operations.PatchV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Input) async throws -> LearnKit.Operations.PatchV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Output {
        fatalError()
    }

    func getV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRulesRuleId.Output {
        fatalError()
    }

    func postV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules(_ input: LearnKit.Operations.PostV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Input) async throws -> LearnKit.Operations.PostV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Output {
        fatalError()
    }

    func getV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules(_ input: LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Input) async throws -> LearnKit.Operations.GetV1CoursesCourseIdContentsContentIdAdaptiveReleaseRules.Output {
        fatalError()
    }

    func getV1Oauth2Tokeninfo(_ input: LearnKit.Operations.GetV1Oauth2Tokeninfo.Input) async throws -> LearnKit.Operations.GetV1Oauth2Tokeninfo.Output {
        fatalError()
    }

    func postV1Oauth2Token(_ input: LearnKit.Operations.PostV1Oauth2Token.Input) async throws -> LearnKit.Operations.PostV1Oauth2Token.Output {
        fatalError()
    }

    func getV1Oauth2Authorizationcode(_ input: LearnKit.Operations.GetV1Oauth2Authorizationcode.Input) async throws -> LearnKit.Operations.GetV1Oauth2Authorizationcode.Output {
        fatalError()
    }
}
