//
//  BrightonApplicationDelegate.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import Foundation
import UIKit
import Router

class ApplicationDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            if let navigation = Navigation(from: shortcutItem) {
                Router.shared.navigate(to: navigation)
                if shortcutItem.type == "search" {
                    SearchManager.shared.focusSearchField()
                }
            }
        }
        
        let config = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.configuration.role)
        config.delegateClass = SceneDelegate.self
        
        return config
    }
}
