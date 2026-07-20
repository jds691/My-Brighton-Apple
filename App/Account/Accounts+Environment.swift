//
//  Accounts+Environment.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import Accounts

private let defaultService: AccountService = AccountService()

extension EnvironmentValues {
    @Entry var accountService: AccountService = defaultService
}

struct AccountServiceAuthenticatedPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> AccountService {
        return AccountService(forcedStatus: .authenticated)
    }

    func body(content: Self.Content, context: AccountService) -> some View {
        content
            .environment(\.accountService, context)
    }
}

extension PreviewTrait {
    static var authenticatedAccount: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(AccountServiceAuthenticatedPreviewModifier())
        )
    }
}

struct AccountServiceUnauthenticatedPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> AccountService {
        return AccountService(forcedStatus: .notAuthenticated)
    }

    func body(content: Self.Content, context: AccountService) -> some View {
        content
            .environment(\.accountService, context)
    }
}

extension PreviewTrait {
    static var unauthenticatedAccount: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(AccountServiceAuthenticatedPreviewModifier())
        )
    }
}

