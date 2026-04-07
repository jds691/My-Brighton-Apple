//
//  BackgroundType+AvgColour.swift
//  My Brighton
//
//  Created by Neo Salmon on 07/04/2026.
//

import Foundation
import simd
import SwiftUI
import CustomisationKit
import CoreImage.CIFilterBuiltins

extension BackgroundType {
    func avgColor(for environment: EnvironmentValues) -> Color {
        var avgColor: Color

        var ciImage: CIImage?
        // Why does this not just render the CustomisedBackgroundView?
        // Because customImage is a URL it's rendered using AsyncImage
        // When it's fetched for rendering only the placeholder is available, causing all images
        // To return the same brightonSecondary grey as their average colour
        //
        // We now let CoreImage load the contents of the URL directly
        switch self {
            case .color(let codableColor):
                return codableColor.resolved
            case .builtInImage(let string):
                let renderer = ImageRenderer(content: Image(string, bundle: Bundle(for: CustomisationService.self)))
                renderer.colorMode = .nonLinear

                if let renderedBackground = renderer.cgImage {
                    ciImage = CIImage(cgImage: renderedBackground)
                }
            case .customImage(let uRL):
                ciImage = CIImage(contentsOf: uRL)
        }

        if let ciImage {
            let extentVector = CIVector(x: ciImage.extent.origin.x, y: ciImage.extent.origin.y, z: ciImage.extent.size.width, w: ciImage.extent.size.height)

            if let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]), let outputImage = filter.outputImage {
                var bitmap = [UInt8](repeating: 0, count: 4)
                let context = CIContext(options: [.workingColorSpace: kCFNull!, .outputColorSpace: kCFNull!])
                context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!)

                avgColor = Color(.sRGB, red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, opacity: CGFloat(bitmap[3]) / 255)
            } else {
                if environment.colorScheme == .dark {
                    avgColor = .black
                } else {
                    avgColor = .white
                }
            }
        } else {
            if environment.colorScheme == .dark {
                avgColor = .black
            } else {
                avgColor = .white
            }
        }

        return avgColor
    }

    func calculateLuminance(for environment: EnvironmentValues) -> Float {
        let resolvedColor = avgColor(for: environment).resolve(in: environment)

        // Thanks Apple for SIMD intrinsics
        let rec709Luma = simd_float3(0.2126, 0.7152, 0.0722)
        let rgb = simd_float3(resolvedColor.linearRed, resolvedColor.linearGreen, resolvedColor.linearBlue)
        let luminance = simd_dot(rec709Luma, rgb)

        if ( luminance <= (216/24389)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
            return luminance * (24389/27);  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
        } else {
            return pow(luminance,(1/3)) * 116 - 16;
        }
    }
}
