//
//  UpdateManager.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/03/2026.
//

import Foundation

@Observable
public class UpdatesManager {
    private let rootDirectory: URL

    public private(set) var isCheckingForUpdates: Bool = false

    init() {
        rootDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton")!
        createPathsIfNeeded()
    }

    // MARK: Paths
    private func createPathsIfNeeded() {
        let fm = FileManager.default
        let ossUpdaterDirectory = rootDirectory.appending(path: "OSSUpdater")
        let stateFile = ossUpdaterDirectory.appending(path: "state.json")

        if !fm.fileExists(atPath: ossUpdaterDirectory.path()) {
            do {
                try fm.createDirectory(at: ossUpdaterDirectory, withIntermediateDirectories: false)
            } catch {
                // TODO: Replace
                fatalError()
            }
        }

        if !fm.fileExists(atPath: stateFile.path()) {
            createStateInfo()
        }
    }
    
    /// Creates an update state file in the shared App Group for My Brighton.
    private func createStateInfo() {
        //Bundle.main.bundleIdentifier
    }
}
