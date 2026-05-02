//
//  AccountService.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import Foundation

@MainActor
@Observable
public final class AccountService: Sendable {
    public private(set) var authenticationStatus: AuthenticationStatus

    private let userDefaults: UserDefaults

#if DEBUG
    private let isStatusForced: Bool
#endif

    public init() {
        self.userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton")!

        if userDefaults.string(forKey: UserDefaultsKeys.lastUserNameHash.rawValue) != nil {
            let expiryInEpochs = userDefaults.double(forKey: UserDefaultsKeys.authExpiryDate.rawValue)

            if Date(timeIntervalSince1970: TimeInterval(floatLiteral: expiryInEpochs)) <= .now {
                self.authenticationStatus = .authenticationExpired
            } else {
                self.authenticationStatus = .authenticated
            }
        } else {
            self.authenticationStatus = .notAuthenticated
        }

#if DEBUG
        self.isStatusForced = false
#endif
    }

    public init(forcedStatus: AuthenticationStatus) {
#if DEBUG
        self.userDefaults = UserDefaults(suiteName: "group.\(Bundle.main.developmentTeamId).com.neo.My-Brighton")!

        self.authenticationStatus = forcedStatus
        self.isStatusForced = true
#else
        self.init()
#endif
    }

    public func signIn(username: String, password: String) async throws(AuthenticationError) {
#if DEBUG
        if isStatusForced {
            if authenticationStatus != .authenticated {
                throw .invalidCredentials
            } else {
                return
            }
        }
#endif

        /*
         This function is hardcoded to accept one set of credentials. This is for demo purposes.

         If this were a real system it would contact an API to accomplish this. This isn't quite possible.
         */
        if username == "exhibition" && password == "day" {
            self.authenticationStatus = .authenticated

            userDefaults.set(username.hash, forKey: UserDefaultsKeys.lastUserNameHash.rawValue)
            // 1 week
            userDefaults.set(Date.now.addingTimeInterval(604800).timeIntervalSince1970, forKey: UserDefaultsKeys.authExpiryDate.rawValue)
        } else {
            throw .invalidCredentials
        }
    }

    public func getAccountDetails() throws(AuthenticationError) -> Account {
        guard self.authenticationStatus == .authenticated else { throw .protectedCall }

        return .exhibitionAccount
    }

    public func signOut() {
#if DEBUG
        if isStatusForced {
            return
        }
#endif

        userDefaults.set(Date.now, forKey: UserDefaultsKeys.authExpiryDate.rawValue)
        self.authenticationStatus = .signedOut
    }

    public func clearAuthenticatedAccount() {
#if DEBUG
        if isStatusForced {
            return
        }
#endif

        userDefaults.removeObject(forKey: UserDefaultsKeys.lastUserNameHash.rawValue)
        userDefaults.set(Date.now, forKey: UserDefaultsKeys.authExpiryDate.rawValue)
        self.authenticationStatus = .notAuthenticated
    }

    public func markAuthenticationExpired() {
#if DEBUG
        if isStatusForced {
            return
        }
#endif
        
        userDefaults.set(Date.now, forKey: UserDefaultsKeys.authExpiryDate.rawValue)
        self.authenticationStatus = .authenticationExpired
    }

    private enum UserDefaultsKeys: String {
        case lastUserNameHash = "Accounts.lastUserNameHash"
        case authExpiryDate = "Accounts.authExpiryDate"
    }
}
