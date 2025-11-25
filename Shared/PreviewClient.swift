//
//  PreviewClient.swift
//  My Brighton
//
//  Created by Neo Salmon on 13/10/2025.
//

import Foundation
import LearnKit
internal import OpenAPIRuntime

struct PreviewClient: APIProtocol {
    let courses: [Components.Schemas.Course] = [
        // Debug
        .init(
            id: "_0_1",
            uuid: nil,
            externalId: nil,
            dataSourceId: nil,
            courseId: "MB_DEBUG",
            name: "Debugging Course",
            description: nil,
            created: .now,
            modified: .now,
            organization: false,
            ultraStatus: .ultra,
            allowGuests: nil,
            allowObservers: nil,
            closedComplete: false,
            termId: "_0_1",
            availability:
                    .init(
                        available: .term,
                        duration: .init(_type: .useTerm, start: nil, end: nil, daysOfUse: nil)
                    ),
            enrollment: .init(_type: .instructorLed, start: nil, end: nil, accessCode: nil),
            locale: .init(id: nil, force: false),
            hasChildren: nil,
            parentId: nil,
            externalAccessUrl: "https://studentcentral.brighton.ac.uk/ultra",
            guestAccessUrl: nil,
            copyHistory: nil
        ),
        // Final Year
        .init(
            id: "_130430_1",
            uuid: nil,
            externalId: nil,
            dataSourceId: nil,
            courseId: "CI601_2025",
            name: "2025 CI601 The Computing Project",
            description: nil,
            created: .now,
            modified: .now,
            organization: false,
            ultraStatus: .ultra,
            allowGuests: nil,
            allowObservers: nil,
            closedComplete: false,
            termId: "_290_1",
            availability:
                    .init(
                        available: .term,
                        duration: .init(_type: .useTerm, start: nil, end: nil, daysOfUse: nil)
                    ),
            enrollment: .init(_type: .instructorLed, start: nil, end: nil, accessCode: nil),
            locale: .init(id: nil, force: false),
            hasChildren: nil,
            parentId: nil,
            externalAccessUrl: "https://studentcentral.brighton.ac.uk/ultra/courses/_130430_1/outline",
            guestAccessUrl: nil,
            copyHistory: nil
        ),
        .init(
            id: "_130438_1",
            uuid: nil,
            externalId: nil,
            dataSourceId: nil,
            courseId: "CI615_2025",
            name: "2025 CI615 Object-Oriented Design and Architecture",
            description: nil,
            created: .now,
            modified: .now,
            organization: false,
            ultraStatus: .ultra,
            allowGuests: nil,
            allowObservers: nil,
            closedComplete: false,
            termId: "_290_1",
            availability:
                    .init(
                        available: .term,
                        duration: .init(_type: .useTerm, start: nil, end: nil, daysOfUse: nil)
                    ),
            enrollment: .init(_type: .instructorLed, start: nil, end: nil, accessCode: nil),
            locale: .init(id: nil, force: false),
            hasChildren: nil,
            parentId: nil,
            externalAccessUrl: "https://studentcentral.brighton.ac.uk/ultra/courses/_130438_1/outline",
            guestAccessUrl: nil,
            copyHistory: nil
        ),
        .init(
            id: "_130441_1",
            uuid: nil,
            externalId: nil,
            dataSourceId: nil,
            courseId: "CI642_2025",
            name: "2025 CI642 Advanced Artificial Intelligence",
            description: nil,
            created: .now,
            modified: .now,
            organization: false,
            ultraStatus: .ultra,
            allowGuests: nil,
            allowObservers: nil,
            closedComplete: false,
            termId: "_290_1",
            availability:
                    .init(
                        available: .term,
                        duration: .init(_type: .useTerm, start: nil, end: nil, daysOfUse: nil)
                    ),
            enrollment: .init(_type: .instructorLed, start: nil, end: nil, accessCode: nil),
            locale: .init(id: nil, force: false),
            hasChildren: nil,
            parentId: nil,
            externalAccessUrl: "https://studentcentral.brighton.ac.uk/ultra/courses/_130441_1/outline",
            guestAccessUrl: nil,
            copyHistory: nil
        ),

        // Second Year
        .init(
            id: "_129556_1",
            uuid: nil,
            externalId: nil,
            dataSourceId: nil,
            courseId: "CI512_2024",
            name: "2024 CI512 Intelligent Systems 1",
            description: nil,
            created: .now,
            modified: .now,
            organization: false,
            ultraStatus: .ultra,
            allowGuests: nil,
            allowObservers: nil,
            closedComplete: false,
            termId: "_164_1",
            availability:
                    .init(
                        available: .term,
                        duration: .init(_type: .useTerm, start: nil, end: nil, daysOfUse: nil)
                    ),
            enrollment: .init(_type: .instructorLed, start: nil, end: nil, accessCode: nil),
            locale: .init(id: nil, force: false),
            hasChildren: nil,
            parentId: nil,
            externalAccessUrl: "https://studentcentral.brighton.ac.uk/ultra/courses/_129556_1/outline",
            guestAccessUrl: nil,
            copyHistory: nil
        )
    ]

    let terms: [Components.Schemas.Term] = [
        .init(
            id: "_0_1",
            externalId: nil,
            dataSourceId: nil,
            name: "DEBUG",
            description: nil,
            availability: .init(available: .yes, duration: .init(_type: .dateRange, start: .now, end: .now, daysOfUse: nil))
        ),
        .init(
            id: "_290_1",
            externalId: nil,
            dataSourceId: nil,
            name: "2025-2026",
            description: nil,
            availability: .init(available: .yes, duration: .init(_type: .dateRange, start: .now, end: .now, daysOfUse: nil))
        ),
        .init(
            id: "_164_1",
            externalId: nil,
            dataSourceId: nil,
            name: "2024-2025",
            description: nil,
            availability: .init(available: .yes, duration: .init(_type: .dateRange, start: .now, end: .now, daysOfUse: nil))
        )
    ]

    let courseContents: Dictionary<String, [Components.Schemas.Content]> = [
        "_0_1": [
            .init(
                id: "0",
                parentId: nil,
                title: "ROOT",
                body: nil,
                description: nil,
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbFolder(.init(value1: .init(id: "resource/x-bb-folder"), value2: .init(isBbPage: false))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
            .init(
                id: "0_0",
                parentId: "0",
                title: "Example Document",
                body: nil,
                description: "Example debugging document from Anthology",
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbFolder(.init(value1: .init(id: "resource/x-bb-folder"), value2: .init(isBbPage: true))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
            .init(
                id: "0_1",
                parentId: "0_0",
                title: "ultraDocumentBody",
                body: "",
                description: "Example debugging document from Anthology",
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbDocument(.init(value1: .init(id: "resource/x-bb-document"))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
        ],

        "_130430_1": [
            .init(
                id: "0",
                parentId: nil,
                title: "ROOT",
                body: nil,
                description: nil,
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbFolder(.init(value1: .init(id: "resource/x-bb-folder"), value2: .init(isBbPage: false))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
        ],
        "_130438_1": [
            .init(
                id: "0",
                parentId: nil,
                title: "ROOT",
                body: nil,
                description: nil,
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbFolder(.init(value1: .init(id: "resource/x-bb-folder"), value2: .init(isBbPage: false))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
        ],
        "_130441_1": [
            .init(
                id: "0",
                parentId: nil,
                title: "ROOT",
                body: nil,
                description: nil,
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbFolder(.init(value1: .init(id: "resource/x-bb-folder"), value2: .init(isBbPage: false))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
        ],

        "_129556_1": [
            .init(
                id: "0",
                parentId: nil,
                title: "ROOT",
                body: nil,
                description: nil,
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: true,
                hasGradebookColumns: nil,
                hasAssociatedGroups: nil,
                launchInNewWindow: false,
                reviewable: false,
                availability: .init(available: .yes, allowGuests: true, allowObservers: true, adaptiveRelease: .init()),
                contentHandler: .resourceXBbFolder(.init(value1: .init(id: "resource/x-bb-folder"), value2: .init(isBbPage: false))),
                copyHistory: nil,
                links: [],
                subtype: nil
            ),
        ]
    ]

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

        return .ok(.init(body: .json(.init(results: courseContents[input.path.courseId]?.filter({ $0.parentId == "0" })))))
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
