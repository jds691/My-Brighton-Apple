//
//  CachedContent.swift
//  My Brighton
//
//  Created by Neo Salmon on 20/11/2025.
//

import Foundation
import SwiftData

@Model
class CachedContent {
    var id: Content.ID
    // Normally this would be Content.parentId but for our use case this is much more practical
    // Will be nil if Content.parentId does not correspond to Content.ID
    var parent: CachedContent?
    var title: String
    var body: String?
    var _description: String?
    var creationDate: Date
    var lastModified: Date
    var positionIndex: Int
    var hasGradebookColumns: Bool?
    var hasAssociatedGroups: Bool?
    var shouldLaunchInNewWindow: Bool
    var isReviewable: Bool
    var availability: CachedContent.Availability
    var handler: CachedContent.Handler
    var links: [CachedContent.Link]
    var subType: String?

    // Relational fields
    var course: CachedCourse?
    @Relationship(inverse: \CachedContent.parent)
    var children: [CachedContent] = []

    init(from contentModel: Content) {
        self.id = contentModel.id
        // Explicitly set by BbCache
        self.parent = nil
        self.title = contentModel.title
        self.body = contentModel.body
        self._description = contentModel.description
        self.creationDate = contentModel.creationDate
        self.lastModified = contentModel.lastModified
        self.positionIndex = contentModel.positionIndex
        self.hasGradebookColumns = contentModel.hasGradebookColumns
        self.hasAssociatedGroups = contentModel.hasAssociatedGroups
        self.shouldLaunchInNewWindow = contentModel.shouldLaunchInNewWindow
        self.isReviewable = contentModel.isReviewable
        self.availability = CachedContent.Availability(from: contentModel.availability)
        self.handler = CachedContent.Handler(from: contentModel.handler)
        self.links = contentModel.links.map { CachedContent.Link(from: $0) }
        self.subType = contentModel.subType

        // Relational fields, will be set by BbCache
        self.course = nil
    }

    func copyValues(from contentModel: Content) {
        self.id = contentModel.id
        // Explicitly set by BbCache
        self.parent = nil
        self.title = contentModel.title
        self.body = contentModel.body
        self._description = contentModel.description
        self.creationDate = contentModel.creationDate
        self.lastModified = contentModel.lastModified
        self.positionIndex = contentModel.positionIndex
        self.hasGradebookColumns = contentModel.hasGradebookColumns
        self.hasAssociatedGroups = contentModel.hasAssociatedGroups
        self.shouldLaunchInNewWindow = contentModel.shouldLaunchInNewWindow
        self.isReviewable = contentModel.isReviewable
        self.availability = CachedContent.Availability(from: contentModel.availability)
        self.handler = CachedContent.Handler(from: contentModel.handler)
        self.links = contentModel.links.map { CachedContent.Link(from: $0) }
        self.subType = contentModel.subType
    }

    enum Handler: Hashable, Codable, Sendable {
        case contentItem
        case externalLink(_ url: URL)
        case contentFolder(isBbPage: Bool)
        case courseLink(target: Course.ID)
        // TODO: Replace later with Discussion.ID
        case discussionLink(target: String)
        case ltiLink(_ url: URL, parameters: String)
        case contentFile(uploadId: String, fileName: String, mimeType: String, duplicateFileHandling: ContentFileDuplicateFileHandelingType?)
        // TODO: target = Assessment.ID, gradeColumn = GradeColumn.ID
        case testLink(target: String, gradeColumn: String)
        // TODO: gradeColumn = GradeColumn.ID
        case assignment(gradeColumn: String, isGroup: Bool)
        case ltiPlacement

        init(from contentHandlerModel: Content.Handler) {
            switch contentHandlerModel {
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

        enum ContentFileDuplicateFileHandelingType: String, RawRepresentable, Hashable, Codable, Sendable {
            case rename = "Rename"
            case replace = "Replace"
            case throwError = "ThrowError"

            init(from contentHandlerFileDuplicateHandelingTypeModel: Content.Handler.ContentFileDuplicateFileHandelingType) {
                switch contentHandlerFileDuplicateHandelingTypeModel {
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

    struct Availability: Hashable, Codable, Sendable {
        let status: Availability.Status
        let allowsGuests: Bool
        let allowsObservers: Bool
        let adaptiveReleaseSettings: Availability.AdaptiveReleaseSettings

        init(from contentAvailabilityModel: Content.Availability) {
            self.status = Availability.Status(from: contentAvailabilityModel.status)
            self.allowsGuests = contentAvailabilityModel.allowsGuests
            self.allowsObservers = contentAvailabilityModel.allowsObservers
            self.adaptiveReleaseSettings = Availability.AdaptiveReleaseSettings(from: contentAvailabilityModel.adaptiveReleaseSettings)
        }

        enum Status: String, RawRepresentable, Hashable, Codable, Sendable {
            case yes = "Yes"
            case no = "No"
            case partial = "PartiallyVisible"

            init(from contentAvailabilityStatusModel: Content.Availability.Status) {
                switch contentAvailabilityStatusModel {
                    case .yes:
                        self = .yes
                    case .no:
                        self = .no
                    case .partial:
                        self = .partial
                }
            }
        }

        struct AdaptiveReleaseSettings: Hashable, Codable, Sendable {
            let availabilityStart: Date?
            let availabilityEnd: Date?

            init(from contentAvailabilityAdaptiveSettingsModel: Content.Availability.AdaptiveReleaseSettings) {
                self.availabilityStart = contentAvailabilityAdaptiveSettingsModel.availabilityStart
                self.availabilityEnd = contentAvailabilityAdaptiveSettingsModel.availabilityEnd
            }
        }
    }

    struct Link: Hashable, Codable, Sendable {
        let href: String
        let rel: String
        let title: String
        let type: String

        init(from contentLinkModel: Content.Link) {
            self.href = contentLinkModel.href
            self.rel = contentLinkModel.rel
            self.title = contentLinkModel.title
            self.type = contentLinkModel.type
        }
    }
}
