//
//  Notifier+Environment.swift
//  My Brighton
//
//  Created by Neo Salmon on 02/05/2026.
//

import SwiftUI
import Notifier

private let defaultService: Notifier = Notifier()

extension EnvironmentValues {
    @Entry var notifier: Notifier = defaultService
}
