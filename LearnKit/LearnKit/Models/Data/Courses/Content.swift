//
//  Content.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import Foundation
import os

public struct Content: Hashable, Identifiable, Sendable {
    private static let logger = Logger(subsystem: "com.neo.LearnKit", category: "Content")

    public let id: String
    public let parentId: String?
    public let title: String
    public let body: String?
    public let description: String?
    public let creationDate: Date
    public let lastModified: Date
    public let positionIndex: Int
    public let hasChildren: Bool
    public let hasGradebookColumns: Bool?
    public let hasAssociatedGroups: Bool?
    public let shouldLaunchInNewWindow: Bool
    public let isReviewable: Bool
    public let availability: Self.Availability
    public let handler: Self.Handler
    public let links: [Self.Link]
    public let subType: String?

    init?(from contentSchema: Components.Schemas.Content) {
        guard
            // Content Fields
            let id = contentSchema.id,
            let title = contentSchema.title,
            let creationDate = contentSchema.created,
            let lastModified = contentSchema.modified,
            let positionIndex = contentSchema.position,
            let hasChildren = contentSchema.hasChildren,
            let shouldLaunchInNewWindow = contentSchema.launchInNewWindow,
            let isReviewable = contentSchema.reviewable,
            let availability = contentSchema.availability,
            let handler = contentSchema.contentHandler,
            let links = contentSchema.links,

            // Required Data Models
            let availabilityModel = Self.Availability(from: availability),
            let handlerModel = Self.Handler(from: handler)
        else {
            Self.logger.error("contentSchema is missing minimum required fields, unable to construct data model.")
#if DEBUG
            dump(contentSchema)
#endif

            return nil
        }

        self.id = id
        self.parentId = contentSchema.parentId
        self.title = title
        self.body = contentSchema.body
        self.description = contentSchema.description
        self.creationDate = creationDate
        self.lastModified = lastModified
        self.positionIndex = Int(positionIndex)
        self.hasChildren = hasChildren
        self.hasGradebookColumns = contentSchema.hasGradebookColumns
        self.hasAssociatedGroups = contentSchema.hasAssociatedGroups
        self.shouldLaunchInNewWindow = shouldLaunchInNewWindow
        self.isReviewable = isReviewable
        self.availability = availabilityModel
        self.handler = handlerModel
        do {
            self.links = try links.map {
                guard let modelLink = Self.Link(from: $0) else {
#if DEBUG
                    dump($0)
#endif
                    throw LearnKitError.unknown(statusCode: nil)
                }

                return modelLink
            }
        } catch {
            Self.logger.error("contentSchema links contains an invalid link. Unable to construct data model. See previous output for problematic link.")
            return nil
        }

        self.subType = contentSchema.subtype
    }

    init?(from cachedContent: CachedContent) {
        self.id = cachedContent.id
        self.parentId = cachedContent.parent?.id
        self.title = cachedContent.title
        self.body = cachedContent.body
        self.description = cachedContent._description
        self.creationDate = cachedContent.creationDate
        self.lastModified = cachedContent.lastModified
        self.positionIndex = cachedContent.positionIndex
        self.hasChildren = !cachedContent.children.isEmpty
        self.hasGradebookColumns = cachedContent.hasGradebookColumns
        self.hasAssociatedGroups = cachedContent.hasAssociatedGroups
        self.shouldLaunchInNewWindow = cachedContent.shouldLaunchInNewWindow
        self.isReviewable = cachedContent.isReviewable
        self.availability = Availability(from: cachedContent.availability)
        self.handler = Handler(from: cachedContent.handler)
        self.links = cachedContent.links.map { Link(from: $0) }
        self.subType = cachedContent.subType
    }

    public enum Handler: Hashable, Sendable {
        case contentItem
        case externalLink(_ url: URL)
        case contentFolder(isBbPage: Bool)
        case courseLink(target: Course.ID)
        // TODO: Replace later with Discussion.ID
        case discussionLink(target: String)
        // I think this is just wrongn
        case ltiLink(_ url: URL, parameters: String)
        case contentFile(uploadId: String, fileName: String, mimeType: String, duplicateFileHandling: ContentFileDuplicateFileHandelingType?)
        // TODO: target = Assessment.ID, gradeColumn = GradeColumn.ID
        case testLink(target: String, gradeColumn: String)
        // TODO: gradeColumn = GradeColumn.ID
        case assignment(gradeColumn: String, isGroup: Bool)
        case ltiPlacement

        init?(from contentHandlerSchema: Components.Schemas.ContentHandler) {
            switch contentHandlerSchema {
                case .resourceXBbAsmtTestLink(let params):
                    self = .testLink(target: params.value2.assessmentId, gradeColumn: params.value2.gradeColumnId)
                case .resourceXBbAssignment(let params):
                    self = .assignment(gradeColumn: params.value2.gradeColumnId, isGroup: params.value2.groupContent)
                case .resourceXBbBltiLink(let params):
                    guard let url = URL(string: params.value2.url) else { return nil }

                    self = .ltiLink(url, parameters: params.value2.customParameters)
                case .resourceXBbCourselink(let params):
                    self = .courseLink(target: params.value2.targetId)
                case .resourceXBbDocument(_):
                    self = .contentItem
                case .resourceXBbExternallink(let params):
                    guard let url = URL(string: params.value2.url) else { return nil }
                    self = .externalLink(url)
                case .resourceXBbFile(let params):
                    self = .contentFile(uploadId: params.value2.file.uploadId, fileName: params.value2.file.fileName, mimeType: params.value2.file.mimeType, duplicateFileHandling: ContentFileDuplicateFileHandelingType(from: params.value2.file.duplicateFileHandling))
                case .resourceXBbFolder(let params):
                    self = .contentFolder(isBbPage: params.value2.isBbPage)
                case .resourceXBbForumlink(let params):
                    self = .discussionLink(target: params.value2.discussionId)
            }
        }

        init(from cachedContentHandler: CachedContent.Handler) {
            switch cachedContentHandler {
                case .contentItem:
                    self = .contentItem
                case .externalLink(let url):
                    self = .externalLink(url)
                case .contentFolder(let isBbPage):
                    self = .contentFolder(isBbPage: isBbPage)
                case .courseLink(let target):
                    self = .courseLink(target: target)
                case .discussionLink(let target):
                    self = .discussionLink(target: target)
                case .ltiLink(let url, let parameters):
                    self = .ltiLink(url, parameters: parameters)
                case .contentFile(let uploadId, let fileName, let mimeType, let duplicateFileHandling):
                    self = .contentFile(uploadId: uploadId, fileName: fileName, mimeType: mimeType, duplicateFileHandling: duplicateFileHandling == nil ? nil : ContentFileDuplicateFileHandelingType(from: duplicateFileHandling!))
                case .testLink(let target, let gradeColumn):
                    self = .testLink(target: target, gradeColumn: gradeColumn)
                case .assignment(let gradeColumn, let isGroup):
                    self = .assignment(gradeColumn: gradeColumn, isGroup: isGroup)
                case .ltiPlacement:
                    self = .ltiPlacement
            }
        }

        public enum ContentFileDuplicateFileHandelingType: String, RawRepresentable, Hashable, Sendable {
            case rename = "Rename"
            case replace = "Replace"
            case throwError = "ThrowError"

            init(from contentHandlerFileInfoSchema: Components.Schemas.ContentHandler_ContentFileTOPub.Value2Payload.FilePayload.DuplicateFileHandlingPayload?) {
                switch contentHandlerFileInfoSchema {
                    case .replace:
                        self = .replace
                    case .throwError:
                        self = .throwError
                    default:
                        self = .rename
                }
            }

            init(from cachedContentHandlerFileDuplicateHandelingTypeModel: CachedContent.Handler.ContentFileDuplicateFileHandelingType) {
                switch cachedContentHandlerFileDuplicateHandelingTypeModel {
                    case .rename:
                        self = .rename
                    case .replace:
                        self = .replace
                    case .throwError:
                        self = .throwError
                }
            }
        }
    }

    public enum State: String, Hashable {
        case none = "None" // Completely inaccessible
        case unlocked = "Unlocked" // Not read
        case started = "Started" // Partially read
        case completed = "Completed" // Fully read
    }

    public struct Availability: Hashable, Sendable {
        public let status: Self.Status
        public let allowsGuests: Bool
        public let allowsObservers: Bool
        public let adaptiveReleaseSettings: Self.AdaptiveReleaseSettings

        init?(from availabilitySchema: Components.Schemas.Content.AvailabilityPayload) {
            guard
                // Content Fields
                let status = availabilitySchema.available,
                let allowGuests = availabilitySchema.allowGuests,
                let allowObservers = availabilitySchema.allowObservers,
                let adaptiveReleaseSettings = availabilitySchema.adaptiveRelease
            else {
                Content.logger.error("availabilitySchema is missing minimum required fields, unable to construct data model.")
#if DEBUG
                dump(availabilitySchema)
#endif

                return nil
            }

            self.status = Status(from: status)
            self.allowsGuests = allowGuests
            self.allowsObservers = allowObservers
            self.adaptiveReleaseSettings = Self.AdaptiveReleaseSettings(from: adaptiveReleaseSettings)
        }

        init(from cachedContentAvailability: CachedContent.Availability) {
            self.status = Availability.Status(from: cachedContentAvailability.status)
            self.allowsGuests = cachedContentAvailability.allowsGuests
            self.allowsObservers = cachedContentAvailability.allowsObservers
            self.adaptiveReleaseSettings = Availability.AdaptiveReleaseSettings(from: cachedContentAvailability.adaptiveReleaseSettings)
        }

        public enum Status: String, RawRepresentable, Hashable, Sendable {
            case yes = "Yes"
            case no = "No"
            case partial = "PartiallyVisible"

            init(from availabilityStatusSchema: Components.Schemas.Content.AvailabilityPayload.AvailablePayload) {
                switch availabilityStatusSchema {
                    case .yes:
                        self = .yes
                    case .no:
                        self = .no
                    case .partiallyVisible:
                        self = .partial
                }
            }

            init(from cachedContentAvailabilityStatus: CachedContent.Availability.Status) {
                switch cachedContentAvailabilityStatus {
                    case .yes:
                        self = .yes
                    case .no:
                        self = .no
                    case .partial:
                        self = .partial
                }
            }
        }

        public struct AdaptiveReleaseSettings: Hashable, Sendable {
            public let availabilityStart: Date?
            public let availabilityEnd: Date?

            init(from availabilityAdaptiveReleaseSettingsSchema: Components.Schemas.Content.AvailabilityPayload.AdaptiveReleasePayload) {
                self.availabilityStart = availabilityAdaptiveReleaseSettingsSchema.start
                self.availabilityEnd = availabilityAdaptiveReleaseSettingsSchema.end
            }

            init(from cachedContentAvailabilityAdaptiveSettings: CachedContent.Availability.AdaptiveReleaseSettings) {
                self.availabilityStart = cachedContentAvailabilityAdaptiveSettings.availabilityStart
                self.availabilityEnd = cachedContentAvailabilityAdaptiveSettings.availabilityEnd
            }
        }
    }

    public struct Link: Hashable, Sendable {
        public let href: String
        public let rel: String
        public let title: String
        public let type: String

        init?(from contentLinkSchema: Components.Schemas.ContentLink) {
            guard
                let href = contentLinkSchema.href,
                let rel = contentLinkSchema.rel,
                let title = contentLinkSchema.title,
                let type = contentLinkSchema._type
            else {
                Content.logger.error("contentLinkSchema is missing minimum required fields, unable to construct data model.")
#if DEBUG
                dump(contentLinkSchema)
#endif

                return nil
            }

            self.href = href
            self.rel = rel
            self.title = title
            self.type = type
        }

        init(from cachedContentLink: CachedContent.Link) {
            self.href = cachedContentLink.href
            self.rel = cachedContentLink.rel
            self.title = cachedContentLink.title
            self.type = cachedContentLink.type
        }
    }
}

extension Content: Comparable {
    public static func < (lhs: Content, rhs: Content) -> Bool {
        return lhs.positionIndex < rhs.positionIndex
    }
}
