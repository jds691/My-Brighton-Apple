//
//  Router.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import Foundation
import os
import SwiftUI

enum Setting: String, Hashable, CaseIterable {
    case general
    case notifications
}

public enum Modal: String, Hashable, Identifiable, CaseIterable {
    public var id: Modal { self }

    case account
    case inbox
    case timetableSetup

    public var windowId: String {
        switch self {
            case .account:
                "account"
            case .inbox:
                "inbox"
            default:
                ""
        }
    }
}

@Observable
public final class Router {
    private static let logger: Logger = Logger(subsystem: "com.neo.My-Brighton", category: "Router")
    public static let shared: Router = Router()

    //@ObservationIgnored
    //private var syncInProgress: Bool = false
    
    public var currentRoute: Navigation.Route = .home(nil)/* {
        didSet {
            if #unavailable(iOS 18) {
                if !syncInProgress {
                    print("Syncing split navigation state")
                    syncInProgress = true
                    splitNavigation = currentRoute
                    syncInProgress = false
                }
            }
        }
    }*/

    // TODO: Allow routes to register their own paths so the router can still control them but not interfere?
    private var paths: [Navigation.Route: NavigationPath] = [:]

    public var path: NavigationPath {
        // TODO: Causes weird transitions to do it this way
        get {
            if let path = paths[currentRoute] {
                return path
            } else {
                paths.updateValue(NavigationPath(), forKey: currentRoute)
                return paths[currentRoute]!
            }
        }

        set {
            paths.updateValue(newValue, forKey: currentRoute)
        }
    }

    public var rootModal: Modal? = nil

    public func navigate(to route: Navigation) {
        switch (route) {
            case .route(_: let route):
                handleRouteNavigation(route)
            case .modal(_: let modal):
                rootModal = modal
        }
    }

    private func handleRouteNavigation(_ route: Navigation.Route) {
        switch route {
            case .home(let homeSubRoute):
                currentRoute = .home(nil)
                if let homeSubRoute {
                    appendToPath(homeSubRoute)
                }
            case .myStudies(let myStudiesSubRoute):
                currentRoute = .myStudies(nil)
                if let myStudiesSubRoute {
                    appendToPath(myStudiesSubRoute)
                }
            // Non-paramitised routes
            default:
                currentRoute = route
        }
    }

    public func resetNavigationPath() {
        path = NavigationPath()
    }

    @available(*, deprecated, message: "Use the enum based varients instead for type safety")
    public func appendToNavigationPath(_ value: any Hashable) {
        path.append(value)
    }

    // MARK: HomeSubRoute
    public func appendToPath(_ subroute: Navigation.Route.HomeSubRoute) {
        guard case .home(let homeSubRoute) = currentRoute else {
            Self.logger.error("Current route is NOT case .home. Ignoring navigation request")
            return
        }

        if homeSubRoute != nil {
            resetNavigationPath()
        }

        path.append(subroute)
    }

    // MARK: MyStudiesSubRoute
    public func appendToPath(_ subroute: Navigation.Route.MyStudiesSubRoute) {
        guard case .myStudies(let myStudiesSubRoute) = currentRoute else {
            Self.logger.error("Current route is NOT case .myStudies. Ignoring navigation request")
            return
        }

        if myStudiesSubRoute != nil {
            resetNavigationPath()
        }

        print(subroute.id)
        path.append(subroute)
        print(path.count)

        switch subroute {
            case .module(_, let moduleSubRoute):
                if let moduleSubRoute {
                    appendToPath(moduleSubRoute)
                }
        }
    }

    // MARK: ModuleSubRoute
    public func appendToPath(_ subroute: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute) {
        guard case .myStudies(let myStudiesSubRoute) = currentRoute else {
            Self.logger.error("Current route is NOT case .myStudies. Ignoring navigation request")
            return
        }

        if myStudiesSubRoute != nil {
            resetNavigationPath()
        }

        print(subroute.id)
        path.append(subroute)
        print(path.count)
    }

    public func navigate(from url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        Self.logger.debug("\(components.scheme!)")

        if components.scheme == "mybrighton" {
            Self.logger.info("Handling deep link: \(url.path())")

            let path = components.path.split(separator: "/", omittingEmptySubsequences: true)
            dump(path)

            // TODO: Let the routes instantiate themselves based on a path component
            if let host = url.host() {
                switch host {
                    case "home":
                        if path.count >= 1 {
                            switch path[0] {
                                case "timetable":
                                    navigate(to: .route(.home(.timetable(nil))))
                                    break
                                default:
                                    break
                            }
                        }
                        break
                    default:
                        break
                }
            }
        } else {

        }
    }

    #if os(iOS)
    public func navigate(from shortcutItem: UIApplicationShortcutItem) {
        switch (shortcutItem.type) {
            case "account":
                self.navigate(to: .modal(.account))
            case "myStudies":
                self.navigate(to: .route(.myStudies(nil)))
            case "search":
                self.navigate(to: .route(.search))
            default:
                print("Unable to navigate to destination: '\(shortcutItem.type)'")
        }
    }
    #endif
}
