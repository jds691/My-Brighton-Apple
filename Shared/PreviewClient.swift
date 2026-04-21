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
    let systemAnnouncements: [Components.Schemas.SystemAnnouncement] = []

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
                body: "<!-- {\"bbMLEditorVersion\":1} --><div data-bbid=\"bbml-editor-id_9c6a9556-80a5-496c-b10d-af2a9ab22d45\"><h2>Header Large</h2><h5>Header Medium</h5><h6>Header Small</h6><p><strong>Bold </strong><em>Italic<span style=\"text-decoration: underline;\">Italic Underline</span></em></p><ul><li><span style=\"text-decoration: underline;\"><em></em></span>Bullet 1</li><li>Bullet 2</li></ul><p><img /></p><p><span>\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.\"</span></p><p><span>&lt;braces test=\"values\" other=\"encoded values\"&gt;</span></p><p>Header Small</p><ol><li>Number 1</li><li>Number 2</li></ol><p>Just words followed by a formula<img align=\"middle\" alt=\"3 divided by 4 2 root of 7\" class=\"Wirisformula\" data-mathml=\"Â«math xmlns=Â¨[http://www.w3.org/1998/Math/MathMLÂ¨Â»Â«mnÂ»3Â«/mnÂ»Â«moÂ»/Â«/moÂ»Â«mnÂ»4Â«/mnÂ»Â«mrootÂ»Â«mnÂ»7Â«/mnÂ»Â«mnÂ»2Â«/mnÂ»Â«/mrootÂ»Â«/mathÂ»](https://community.blackboard.com/external-link.jspa?url=http%3A//www.w3.org/1998/Math/MathML%25C2%25A8%25C2%25BB%25C2%25ABmn%25C2%25BB3%25C2%25AB/mn%25C2%25BB%25C2%25ABmo%25C2%25BB/%25C2%25AB/mo%25C2%25BB%25C2%25ABmn%25C2%25BB4%25C2%25AB/mn%25C2%25BB%25C2%25ABmroot%25C2%25BB%25C2%25ABmn%25C2%25BB7%25C2%25AB/mn%25C2%25BB%25C2%25ABmn%25C2%25BB2%25C2%25AB/mn%25C2%25BB%25C2%25AB/mroot%25C2%25BB%25C2%25AB/math%25C2%25BB)\" /></p><p><a href=\"[http://www.blackboard.com](https://community.blackboard.com/external-link.jspa?url=http%3A//www.blackboard.com/)\">Blackboard</a></p></div>",
                description: "Example debugging document from Anthology",
                created: .now,
                modified: .now,
                position: 0,
                hasChildren: false,
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

    let courseAnnouncements: Dictionary<String, [Components.Schemas.CourseAnnouncement]> = [
        "_0_1" : [
            .init(
                id: "_0_1",
                title: "Test announcement #1",
                body: "<p><strong>PLEASE</strong> work.</p>",
                draft: false,
                availability: .init(
                    duration: .init(
                        _type: .permanent,
                        start: nil,
                        end: nil
                    )
                ),
                creatorUserId: "_691_1",
                created: .now,
                modified: .now,
                participants: nil,
                position: 0,
                readCount: nil,
                creator: nil
            ),
            .init(
                id: "_1_1",
                title: "Test announcement #2",
                body: "<p>Omg it does.</p>",
                draft: false,
                availability: .init(
                    duration: .init(
                        _type: .permanent,
                        start: nil,
                        end: nil
                    )
                ),
                creatorUserId: "_691_1",
                created: .now,
                modified: .now,
                participants: nil,
                position: 1,
                readCount: nil,
                creator: nil
            ),
            .init(
                id: "_2_1",
                title: "Test announcement #3",
                body: "<h4><strong>YIPPEE :3</strong></h4>",
                draft: false,
                availability: .init(
                    duration: .init(
                        _type: .permanent,
                        start: nil,
                        end: nil
                    )
                ),
                creatorUserId: "_691_1",
                created: .now,
                modified: .now,
                participants: nil,
                position: 2,
                readCount: nil,
                creator: nil
            ),
            .init(
                id: "_3_1",
                title: "Test announcement #4",
                body: "<math><mrow></mrow></math>",
                draft: false,
                availability: .init(
                    duration: .init(
                        _type: .permanent,
                        start: nil,
                        end: nil
                    )
                ),
                creatorUserId: "_691_1",
                created: .now,
                modified: .now,
                participants: nil,
                position: 3,
                readCount: nil,
                creator: nil
            ),
            .init(
                id: "_4_1",
                title: "Test announcement #5",
                body: "<a></>",
                draft: false,
                availability: .init(
                    duration: .init(
                        _type: .permanent,
                        start: nil,
                        end: nil
                    )
                ),
                creatorUserId: "_691_1",
                created: .now,
                modified: .now,
                participants: nil,
                position: 4,
                readCount: nil,
                creator: nil
            )
        ]
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

    // TODO: Implement Gradebook API
    func getV2CoursesCourseIdGradebookColumns(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumns.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumns.Output {
        fatalError()
    }

    func getV2CoursesCourseIdGradebookColumnsColumnId(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnId.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnId.Output {
        fatalError()
    }

    func getV2CoursesCourseIdGradebookColumnsColumnIdAttempts(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttempts.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttempts.Output {
        fatalError()
    }

    func getV2CoursesCourseIdGradebookColumnsColumnIdAttemptsAttemptId(_ input: LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttemptsAttemptId.Input) async throws -> LearnKit.Operations.GetV2CoursesCourseIdGradebookColumnsColumnIdAttemptsAttemptId.Output {
        fatalError()
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
