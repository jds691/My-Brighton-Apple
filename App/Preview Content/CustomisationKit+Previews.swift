//
//  CustomisationKit+Previews.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/04/2026.
//

import SwiftUI
import CustomisationKit

struct CustomisationKitPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> CustomisationService {
        return CustomisationService(inMemory: true)
    }

    func body(content: Self.Content, context: CustomisationService) -> some View {
        content
            .environment(\.customisationService, context)
    }
}

extension PreviewTrait {
    static var customisationKit: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(CustomisationKitPreviewModifier())
        )
    }
}

