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
                Image(decorative: resourcePath, bundle: Bundle(for: CustomisationService.self))
                    .resizable()
            case .customImage(let url):
                AsyncImage(url: url) {
                    $0
                        .resizable()
                } placeholder: {
                    Color.brightonSecondary
                }
                .accessibilityHidden(true)
        }
    }
}
