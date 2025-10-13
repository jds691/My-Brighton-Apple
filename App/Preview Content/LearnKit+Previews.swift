//
//  LearnKit+Previews.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/08/2025.
//

import SwiftUI
import LearnKit

public extension EnvironmentValues {
     @Entry var learnKitService: LearnKitService = LearnKitService(learnInstanceURL: .init(string: "https://example.com")!)
}

struct LearnKitPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> LearnKitService {
        return LearnKitService(client: PreviewClient())
    }

    func body(content: Self.Content, context: LearnKitService) -> some View {
        content
            .environment(\.learnKitService, context)
    }
}

extension PreviewTrait {
    static var learnKit: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(LearnKitPreviewModifier())
        )
    }
}
