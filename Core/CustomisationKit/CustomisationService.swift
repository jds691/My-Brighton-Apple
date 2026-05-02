//
//  CustomisationService.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import Foundation
import SwiftData
import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CoreImage
import CoreImage.CIFilterBuiltins

nonisolated
public final class CustomisationService {
    nonisolated(unsafe) public static var inMemoryOnly: Bool = false

    private static let schemaV1: Schema = .init([
        CourseCustomisation.self,
        HomeCustomisation.self
    ])

    // Also copied from LearnKit
    private var modelExecutor: any ModelExecutor
    private var modelContainer: ModelContainer
    private var modelContext: ModelContext { modelExecutor.modelContext }

    private let graphicsContext: CIContext

    // NotifcaitonCenter
    public static let thumbnailDidRefresh = NSNotification.Name(rawValue: "com.neo.CustomisationKit.CustomisationService.thumbnailDidRefresh")

    nonisolated(unsafe) private static var _shared: CustomisationService? = nil
    public static var shared: CustomisationService {
        if let _shared {
            return _shared
        } else {
            _shared = CustomisationService()
            return _shared!
        }
    }

    private init() {
        graphicsContext = CIContext(options: [.workingColorSpace: kCFNull!, .outputColorSpace: kCFNull!])

        do {
            let config: ModelConfiguration = .init("Customisation", schema: Self.schemaV1, isStoredInMemoryOnly: Self.inMemoryOnly, groupContainer: .identifier("group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton"))

            self.modelContainer = try .init(for: Self.schemaV1, configurations: config)
            self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))

            self.modelContext.autosaveEnabled = false
        } catch {
            fatalError("Failed to initialise modelContainer, unable to continue.")
        }
    }

    // TODO: Caching
    public static func getBuiltInImageCollections() throws -> [ImageCollection] {
        guard let collectionsData = NSDataAsset(name: "Collections", bundle: .init(for: CustomisationService.self)) else { throw DecodingError.valueNotFound(NSDataAsset.self, .init(codingPath: [], debugDescription: "Sourced from CustomisationKit BuiltIn Images.xcasset")) }

        return try JSONDecoder().decode([ImageCollection].self, from: collectionsData.data)
    }

    public static func getAlwaysPresentImagePath() -> String {
        "safety"
    }

    public static func getBuiltInColours() -> [Color] {
        [
            .accent,
            .colibri1,
            .colibri2,
            .colibri3,
            .colibri4
        ]
    }

    public func eraseAll() async throws {
        try modelContext.delete(model: CourseCustomisation.self)
        try modelContext.delete(model: HomeCustomisation.self)

        try modelContext.save()
    }

    public func getCourseCustomisation(for courseId: String) -> CourseCustomisation {
        do {
            var descriptor = FetchDescriptor<CourseCustomisation>(predicate: #Predicate { $0.courseId == courseId })
            descriptor.fetchLimit = 1

            if let result = try modelContext.fetch(descriptor).first {
                return result
            }

            let customisation = CourseCustomisation()
            customisation.courseId = courseId

            modelContext.insert(customisation)
            try modelContext.save()

            return customisation
        } catch {
            print(error)
            // TODO: Log error
            return CourseCustomisation()
        }
    }

    public func getHomeCustomisation() -> HomeCustomisation {
        do {
            var descriptor = FetchDescriptor<HomeCustomisation>()
            descriptor.fetchLimit = 1

            if let result = try modelContext.fetch(descriptor).first {
                return result
            }

            let customisation = HomeCustomisation()

            modelContext.insert(customisation)
            try modelContext.save()

            return customisation
        } catch {
            print(error)
            // TODO: Log error
            return HomeCustomisation()
        }
    }

    public func discordOutstandingChanges() {
        modelContext.rollback()
    }

    public func saveOutstandingChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Saving CustomisationService changes failed:")
            print(error)
        }
    }

    public static func storePhotosPickerProfilePictureItem(_ item: PhotosPickerItem) async throws -> URL {
        guard let url = try await item.loadTransferable(type: PhotosItemURL.self) else { throw PhotosItemURL.ImportError.unknown }

        // TODO: Downscale macOS images too
        // Not done rn because of it requiring CoreImage
        #if canImport(UIKit)
        let image = UIImage(contentsOfFile: url.url.path(percentEncoded: false))

        if let scaledImage = await image?.byPreparingThumbnail(ofSize: CGSize(width: 240, height: 240)) {
            try scaledImage.heicData()?.write(to: url.url, options: .atomic)
        }
        #endif

        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Home", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let uuid = UUID()
        let customImageFile = customImageCache.appending(path: uuid.uuidString, directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            return try fm.replaceItemAt(customImageFile, withItemAt: url.url, backupItemName: "PFP_BAK") ?? customImageFile
        } else {
            try fm.copyItem(at: url.url, to: customImageFile)
        }

        return customImageFile
    }

    #if canImport(UIKit)
    public static func storeProfilePicture(_ uiImage: UIImage) async throws -> URL {
        var finalImage: UIImage = uiImage
        if let scaledImage = await uiImage.byPreparingThumbnail(ofSize: CGSize(width: 240, height: 240)) {
            finalImage = scaledImage
        }

        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Home", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let uuid = UUID()
        let customImageFile = customImageCache.appending(path: uuid.uuidString, directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            try fm.removeItem(at: customImageFile)
        }

        fm.createFile(atPath: customImageFile.path(percentEncoded: false), contents: finalImage.pngData())

        return customImageFile
    }
    #endif

    public static func storePhotosPickerBackgroundItem(_ item: PhotosPickerItem, for courseId: String) async throws -> URL {
        guard let url = try await item.loadTransferable(type: PhotosItemURL.self) else { throw PhotosItemURL.ImportError.unknown }

        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Course", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let uuid = UUID()
        let customImageFile = customImageCache.appending(path: uuid.uuidString, directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            return try fm.replaceItemAt(customImageFile, withItemAt: url.url, backupItemName: courseId + "_BAK") ?? customImageFile
        } else {
            try fm.copyItem(at: url.url, to: customImageFile)
        }

        return customImageFile
    }

#if canImport(UIKit)
    public static func storeBackgroundImage(_ uiImage: UIImage, for courseId: String) async throws -> URL {
        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Course", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let uuid = UUID()
        let customImageFile = customImageCache.appending(path: uuid.uuidString, directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            try fm.removeItem(at: customImageFile)
        }

        fm.createFile(atPath: customImageFile.path(percentEncoded: false), contents: uiImage.pngData())

        return customImageFile
    }
#endif

    public static func storePhotosPickerBackgroundItem(_ item: PhotosPickerItem) async throws -> URL {
        guard let url = try await item.loadTransferable(type: PhotosItemURL.self) else { throw PhotosItemURL.ImportError.unknown }

        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Home", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let customImageFile = customImageCache.appending(path: "Background", directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            return try fm.replaceItemAt(customImageFile, withItemAt: url.url, backupItemName: "Background_BAK") ?? customImageFile
        } else {
            try fm.copyItem(at: url.url, to: customImageFile)
        }

        return customImageFile
    }

#if canImport(UIKit)
    public static func storeBackgroundImage(_ uiImage: UIImage) async throws -> URL {
        let fm = FileManager.default

        guard let appGroup = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") else { throw PhotosItemURL.ImportError.appGroupSecurity }
        let customImageCache = appGroup.appending(path: "Library", directoryHint: .isDirectory).appending(path: "Application Support", directoryHint: .isDirectory).appending(path: "Customisation", directoryHint: .isDirectory).appending(path: "Images", directoryHint: .isDirectory).appending(path: "Home", directoryHint: .isDirectory)

        if !fm.fileExists(atPath: customImageCache.path(percentEncoded: false)) {
            try fm.createDirectory(at: customImageCache, withIntermediateDirectories: true)
        }

        let customImageFile = customImageCache.appending(path: "Background", directoryHint: .notDirectory)

        if fm.fileExists(atPath: customImageFile.path(percentEncoded: false)) {
            try fm.removeItem(at: customImageFile)
        }

        fm.createFile(atPath: customImageFile.path(percentEncoded: false), contents: uiImage.pngData())

        return customImageFile
    }
#endif
}

// MARK: Thumbnail
extension CustomisationService {
    var courseThumbnailDirectory: URL? {
        if let appGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton") {
            let url = appGroup
                .appending(path: "Library", directoryHint: .isDirectory)
                .appending(path: "Application Support", directoryHint: .isDirectory)
                .appending(path: "Customisation", directoryHint: .isDirectory)
                .appending(path: "Images", directoryHint: .isDirectory)
                .appending(path: "Course", directoryHint: .isDirectory)
                .appending(path: "Thumbnails", directoryHint: .isDirectory)

            if !FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                } catch {
                    print(error)
                }
            }

            return url
        } else {
            return nil
        }
    }
    // For first launch *nothing* will have thumbnails
    @concurrent
    public func updateThumbnail(for courseId: String, fallbackName: String) async {
        let customisations = getCourseCustomisation(for: courseId)

        var backgroundImage: CIImage?

        switch customisations.background {
            case .color(let codableColor):
                let resolved = codableColor.resolved.resolve(in: EnvironmentValues())
                let colourImage = CIImage.init(color: .init(red: CGFloat(resolved.red), green: CGFloat(resolved.green), blue: CGFloat(resolved.blue), alpha: CGFloat(resolved.opacity), colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!) ?? CIColor.gray)
                backgroundImage = colourImage.cropped(to: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1024, height: 1024)))
            case .builtInImage(let string):
                #if canImport(UIKit)
                backgroundImage = CIImage(image: UIImage(named: string, in: Bundle(for: Self.self), with: nil) ?? UIImage())
                #elseif canImport(AppKit)
                // Dear fucking GOD macOS
                backgroundImage = CIImage(data: (Bundle(for: Self.self).image(forResource: string)?.tiffRepresentation(using: .none, factor: 0.0) ?? NSImage().tiffRepresentation(using: .none, factor: 0.0)) ?? Data())
                #endif
            case .customImage(let uRL):
                backgroundImage = CIImage(contentsOf: uRL)
        }

        #if os(iOS)
        var shadow: NSShadow = {
            var shadowInfo = NSShadow()
            shadowInfo.shadowBlurRadius = 9.3
            shadowInfo.shadowColor = UIColor.black

            return shadowInfo
        }()

        var font: UIFont = {
            var traits: UIFontDescriptor.SymbolicTraits = []

            if customisations.textEffects.contains(.bold) {
                traits.insert(.traitBold)
            }

            if customisations.textEffects.contains(.italics) {
                traits.insert(.traitItalic)
            }

            // Yes really, 459px
            let baseDescriptor = UIFont.systemFont(ofSize: 459).fontDescriptor
            let customisedDescriptor = baseDescriptor
                .withDesign(customisations.fontDesign.uiFontDescriptorDesign)?
                .withSymbolicTraits(traits)


            return UIFont(descriptor: customisedDescriptor ?? baseDescriptor, size: 459)
        }()

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(customisations.textColor.resolved),
            .strikethroughStyle: customisations.textEffects.contains(.strikethrough) ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughColor: UIColor(customisations.textColor.resolved),
            .underlineStyle: customisations.textEffects.contains(.underline) ? NSUnderlineStyle.single.rawValue : 0,
            .underlineColor: UIColor(customisations.textColor.resolved)
        ]
        if customisations.textEffects.contains(.dropShadow) {
            attributes.updateValue(shadow, forKey: .shadow)
        }

        let imageText = NSAttributedString(
            string: String(customisations.displayNameOverride?.prefix(1) ?? fallbackName.prefix(1)),
            attributes: attributes
        )
        #else
        var shadow: NSShadow = {
            var shadowInfo = NSShadow()
            shadowInfo.shadowBlurRadius = 9.3
            shadowInfo.shadowColor = NSColor.black

            return shadowInfo
        }()

        var font: NSFont = {
            var traits: NSFontDescriptor.SymbolicTraits = []

            if customisations.textEffects.contains(.bold) {
                traits.insert(.bold)
            }

            if customisations.textEffects.contains(.italics) {
                traits.insert(.italic)
            }

            // Yes really, 459px
            let baseDescriptor = NSFont.systemFont(ofSize: 459).fontDescriptor
            let customisedDescriptor = baseDescriptor
                .withDesign(customisations.fontDesign.nsFontDescriptorDesign)?
                .withSymbolicTraits(traits)


            return NSFont(descriptor: customisedDescriptor ?? baseDescriptor, size: 459) ?? NSFont.systemFont(ofSize: 459)
        }()

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(customisations.textColor.resolved),
            .strikethroughStyle: customisations.textEffects.contains(.strikethrough) ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughColor: NSColor(customisations.textColor.resolved),
            .underlineStyle: customisations.textEffects.contains(.underline) ? NSUnderlineStyle.single.rawValue : 0,
            .underlineColor: NSColor(customisations.textColor.resolved)
        ]
        if customisations.textEffects.contains(.dropShadow) {
            attributes.updateValue(shadow, forKey: .shadow)
        }

        let imageText = NSAttributedString(
            string: String(customisations.displayNameOverride?.prefix(1) ?? fallbackName.prefix(1)),
            attributes: attributes
        )
        #endif

        let textFilter = CIFilter.attributedTextImageGenerator()
        textFilter.text = imageText

        let textImage = textFilter.outputImage

        var pngData: Data?
        if let textImage, let backgroundImage {
            let backgroundLength = min(backgroundImage.extent.width, backgroundImage.extent.height)
            let backgroundX = backgroundImage.extent.width / 2 - backgroundLength / 2
            let backgroundY = backgroundImage.extent.height / 2 - backgroundLength / 2
            let backgroundCropRect = CGRect(x: backgroundX, y: backgroundY, width: backgroundLength, height: backgroundLength)

            let croppedBackground = backgroundImage.cropped(to: backgroundCropRect)

            var scaledBackground: CIImage?
            if backgroundLength != 1024 {
                let scale = 1024 / backgroundLength

                let scaleFilter = CIFilter.lanczosScaleTransform()
                scaleFilter.scale = Float(scale)
                scaleFilter.aspectRatio = 1.0
                scaleFilter.inputImage = croppedBackground

                scaledBackground = scaleFilter.outputImage
            }

            let tX = scaledBackground?.extent.origin.x ?? croppedBackground.extent.origin.x
            let centerX = 512 - (textImage.extent.size.width / 2)
            let tY = scaledBackground?.extent.origin.y ?? croppedBackground.extent.origin.y
            let centerY = 512 - (textImage.extent.size.height / 2)

            let transformation = CGAffineTransform(translationX: tX + centerX, y: tY + centerY)
            let output = textImage.transformed(by: transformation).composited(over: scaledBackground ?? croppedBackground)

            pngData = graphicsContext.pngRepresentation(of: output, format: .RGBA8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!)
        } else {
            pngData = graphicsContext.pngRepresentation(of: CIImage.gray, format: .RGBA8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!)
        }

        if let thumbnailFile = thumbnailUrl(for: courseId) {
            let fm = FileManager.default
            if fm.fileExists(atPath: thumbnailFile.path(percentEncoded: false)) {
                do {
                    try fm.removeItem(at: thumbnailFile)
                } catch {
                    print(error)
                    return
                }
            }

            fm.createFile(atPath: thumbnailFile.path(percentEncoded: false), contents: pngData)

            NotificationCenter.default.post(name: Self.thumbnailDidRefresh, object: nil, userInfo: ["courseId": courseId])
        }
    }

    public func thumbnailUrl(for courseId: String, nilIfNonExistent: Bool = false) -> URL? {
        guard let courseThumbnailDirectory else { return nil }

        if !nilIfNonExistent {
            return courseThumbnailDirectory.appending(path: courseId, directoryHint: .notDirectory)
        }

        if !FileManager.default.fileExists(atPath: courseThumbnailDirectory.appending(path: courseId, directoryHint: .notDirectory).path(percentEncoded: false)) {
            return nil
        }

        return courseThumbnailDirectory.appending(path: courseId, directoryHint: .notDirectory)
    }
}
