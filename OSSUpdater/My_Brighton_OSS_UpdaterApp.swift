//
//  My_Brighton_OSS_UpdaterApp.swift
//  My-Brighton.OSS-Updater
//
//  Created by Neo Salmon on 27/02/2026.
//

import AppKit
import SwiftUI

@main
struct My_Brighton_OSS_UpdaterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NSApplication.shared.terminate(nil)
                }
        }
    }
}
