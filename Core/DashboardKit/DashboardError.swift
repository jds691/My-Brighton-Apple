//
//  DashboardError.swift
//  DashboardKit
//
//  Created by Neo Salmon on 25/03/2026.
//

public enum DashboardError: Error {
    // MARK: Configuration Errors
    /// The dashboard the content is being posted to is not registered.
    case dashboardDoesNotExist
    /// No category is registered that can handle the provided entry.
    case noValidCategory

    // MARK: SwiftData Errors
    /// The underlying model context was unable to save the entry.
    case saveFailed
}
