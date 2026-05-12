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

    case timetableSetup

    public var windowId: String {
        switch self {
            default:
                ""
        }
    }
}

@Observable
@MainActor
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

    private var paths: [Navigation.Route: NavigationPath] = [:]

    @available(*, deprecated, message: "Trust")
    public var path: NavigationPath {
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

    public func getPathBinding(for route: Navigation.Route) -> Binding<NavigationPath> {
        return Binding(get: { [weak self] in
            if let path = self?.paths[route] {
                return path
            } else {
                if let self {
                    self.paths.updateValue(NavigationPath(), forKey: route)
                    if let path = self.paths[route] {
                        return path
                    } else {
                        Self.logger.error("self.paths[route] in `\(#function)` Binding closure is nil. Returning empty NavigationPath")
                        return NavigationPath()
                    }
                } else {
                    Self.logger.error("self in `\(#function)` Binding closure is nil. Returning empty NavigationPath")
                    return NavigationPath()
                }
            }
        }, set: { [weak self] newValue in
            self?.paths.updateValue(newValue, forKey: route)
        })
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
                switch myStudiesSubRoute {
                    case .module(let courseId, let moduleSubRoute):
                        #if os(iOS)
                        if UITraitCollection.current.horizontalSizeClass == .regular {
                            currentRoute = .myStudies(.module(courseId, nil))
                            if let moduleSubRoute {
                                appendToPath(moduleSubRoute)
                            }
                        } else {
                            currentRoute = .myStudies(nil)
                            appendToPath(myStudiesSubRoute!)
                        }
                        #else
                        currentRoute = .myStudies(.module(courseId, nil))
                        if let moduleSubRoute {
                            appendToPath(moduleSubRoute)
                        }
                        #endif
                    case .none:
                        #if os(macOS)
                        Self.logger.error("My Studies navigation on macOS requires a subroute! Cannot navigate!")
                        return
                        #else
                        currentRoute = .myStudies(nil)
                        #endif
                }
            // Non-paramitised routes
            default:
                currentRoute = route
        }
    }

    public func resetNavigationPath() {
        paths.updateValue(NavigationPath(), forKey: currentRoute)
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

        if !paths.contains(where: { (key, value) in key == currentRoute }) {
            paths.updateValue(NavigationPath(), forKey: currentRoute)
        }
        self.paths[currentRoute]?.append(subroute)
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
        if !paths.contains(where: { (key, value) in key == currentRoute }) {
            paths.updateValue(NavigationPath(), forKey: currentRoute)
        }
        self.paths[currentRoute]?.append(subroute)
        print(paths[currentRoute]?.count ?? "IDK")

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
        if !paths.contains(where: { (key, value) in key == currentRoute }) {
            paths.updateValue(NavigationPath(), forKey: currentRoute)
        }
        self.paths[currentRoute]?.append(subroute)
    }
}
