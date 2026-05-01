//
//  Accounts+Environment.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import Accounts

extension EnvironmentValues {
    @Entry var accountService: AccountService = AccountService()
}
