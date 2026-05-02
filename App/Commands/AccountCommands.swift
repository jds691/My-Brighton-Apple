//
//  AccountCommands.swift
//  My Brighton
//
//  Created by Neo Salmon on 24/06/2025.
//

import SwiftUI
import Accounts

struct AccountCommands: Commands {
    private let accountService: AccountService

    @Binding private var showSignOut: Bool

    init(showSignOut: Binding<Bool>, accountService: AccountService) {
        self._showSignOut = showSignOut
        self.accountService = accountService
    }

    var body: some Commands {
        #if os(macOS)
        CommandGroup(before: .appTermination) {
            Button {
                showSignOut = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            .disabled(accountService.authenticationStatus != .authenticated)
        }
        #else
        EmptyCommands()
        #endif
    }
}
