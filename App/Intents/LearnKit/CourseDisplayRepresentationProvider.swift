//
//  CourseDisplayRepresentationProvider.swift
//  My Brighton
//
//  Created by Neo Salmon on 09/04/2026.
//

import AppIntents
import LearnKit
import CustomisationKit
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/*struct CourseDisplayRepresentationProvider: DisplayRepresentationProvider<CourseEntity> {
    private let context: CIContext

    init() {
        context = CIContext(options: [.workingColorSpace: kCFNull!, .outputColorSpace: kCFNull!])
    }

    func representation(for entity: CourseEntity) -> DisplayRepresentation? {
        /*let customisations = CustomisationService.shared.getCourseCustomisation(for: entity.id)

        if let customThumbnail = createThumbnail(entity, customisations) {
            return DisplayRepresentation(title: "\(customisations.displayNameOverride ?? entity.name)", image: .init(data: customThumbnail))
        } else {
            return DisplayRepresentation(title: "\(customisations.displayNameOverride ?? entity.name)", image: .init(systemName: "xmark", isTemplate: true))
        }*/
        nil
    }

    private func createThumbnail(_ entity: CourseEntity, _ customisations: CourseCustomisation) -> Data? {
        var backgroundImage: CIImage?

        switch customisations.background {
            case .color(let codableColor):
                let resolved = codableColor.resolved.resolve(in: EnvironmentValues())
                backgroundImage = CIImage.init(color: .init(red: CGFloat(resolved.red), green: CGFloat(resolved.green), blue: CGFloat(resolved.blue), alpha: CGFloat(resolved.opacity), colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!) ?? CIColor.gray)
            case .builtInImage(let string):
                backgroundImage = CIImage(image: UIImage(named: string, in: Bundle(for: CustomisationService.self), with: nil) ?? UIImage())
            case .customImage(let uRL):
                backgroundImage = CIImage(contentsOf: uRL)
        }

        let textFilter = CIFilter.attributedTextImageGenerator()
        textFilter.text = .init(string: "TEST")

        let textImage = textFilter.outputImage

        if let textImage, let backgroundImage {
            let output = textImage.composited(over: backgroundImage)
            let croppedOutput = output.cropped(to: CGRect(origin: CGPoint(x: output.extent.width / 2, y: output.extent.height / 2), size: CGSize(width: 256, height: 256)))
            return context.pngRepresentation(of: croppedOutput, format: .RGBA8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!)
        } else {
            return context.pngRepresentation(of: CIImage.gray, format: .RGBA8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!)
        }
    }
}
*/
