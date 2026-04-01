//
//  CustomisedBackgroundView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import SwiftUI
import CustomisationKit

struct CustomisedBackgroundView: View {
    var backgroundType: BackgroundType

    init(_ backgroundType: BackgroundType) {
        self.backgroundType = backgroundType
    }

    var body: some View {
        switch backgroundType {
            case .color(let color):
                color.resolved
            case .builtInImage(let resourcePath):
                Image(resourcePath, bundle: Bundle(for: CustomisationService.self))
            @unknown default:
                Color.brightonSecondary
        }
    }
}
