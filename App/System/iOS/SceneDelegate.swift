//
//  SceneDelegate.swift
//  My Brighton
//
//  Created by Neo on 26/08/2023.
//

import UIKit
import Router

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @MainActor
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        guard let navigation = Navigation(from: shortcutItem) else { return false }
        
        Router.shared.navigate(to: navigation)
        if shortcutItem.type == "search" {
            SearchManager.shared.focusSearchField()
        }

        return true
    }
}
