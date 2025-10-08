//
//  PreviewEnvironmentObjects.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import Foundation
import SwiftUI
import Router

struct RouterEnvironmentObject: PreviewModifier {
    static func makeSharedContext() throws -> Router {
        return Router.shared
    }
    
    func body(content: Content, context: Router) -> some View {
        content
            .environment(context)
    }
}

struct SearchManagerEnvironmentObject: PreviewModifier {
    static func makeSharedContext() throws -> SearchManager {
        return SearchManager.shared
    }
    
    func body(content: Content, context: SearchManager) -> some View {
        content
            .environment(context)
    }
}

@available(iOS 18.0, macOS 15.0, *)
extension PreviewTrait {
    static var environmentObjects: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(RouterEnvironmentObject()),
            .modifier(SearchManagerEnvironmentObject())
        )
    }
}
