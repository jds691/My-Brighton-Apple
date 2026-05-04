//
//  OnContinueRouterUserActivitiesViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/09/2025.
//

import SwiftUI
import CoreSpotlight
import LearnKit

public struct OnContinueRouterUserActivitiesViewModifier: ViewModifier {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openURL) private var openURL

    @Environment(Router.self) private var router

    private let learnKit: LearnKitService

    init(learnKit: LearnKitService) {
        self.learnKit = learnKit
    }

    public func body(content: Self.Content) -> some View {
        content
        // MARK: URL navigation
            .onOpenURL { url in
                if let navigation = Navigation(from: url) {
                    router.navigate(to: navigation)
                }
            }
        // MARK: System
            .onContinueUserActivity(CSSearchableItemActionType) { activity in
                guard let itemIdentifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }

                if itemIdentifier.starts(with: "content/") {
                    Task {
                        await handleLearnKitContentNavigation(for: itemIdentifier)
                    }
                } else if let route = Navigation.Route(spotlightIdentifier: itemIdentifier) {
                    router.navigate(to: .route(route))
                }
            }
        // MARK: Routes
            .onContinueUserActivity(UserActivity.Timetable.view) { activity in
                router.navigate(to: .route(.home(.timetable(activity.userInfo?["date"] as? Date))))
            }
        // MARK: Routes - My Studies
            .onContinueUserActivity(UserActivity.MyStudies.Content.view) { activity in
                guard let courseId = activity.userInfo?["courseID"] as? Course.ID, let contentId = activity.userInfo?["contentID"] as? LearnKit.Content.ID else { return }

                router.navigate(to: .route(.myStudies(.module(courseId, .content(contentId)))))
            }
            .onContinueUserActivity(UserActivity.MyStudies.Course.Announcement.view) { activity in
                guard let announcementId = activity.userInfo?["announcementID"] as? CourseAnnouncement.ID else { return }

                if let courseId = activity.userInfo?["courseID"] as? Course.ID {
                    if supportsMultipleWindows {
#if os(macOS)
                        openWindow(id: "course-announcement", value: CourseAnnouncementIDUnion(courseId: courseId, announcementId: announcementId))
#else
                        router.navigate(to: .route(.myStudies(.module(courseId, .announcements(announcementId)))))
#endif
                    } else {
                        router.navigate(to: .route(.myStudies(.module(courseId, .announcements(announcementId)))))
                    }
                } else {
                    // TODO: Handle system announcements
                }
            }
    }

    private func handleLearnKitContentNavigation(for itemIdentifier: String) async {
        let components = itemIdentifier.split(separator: "/")
        guard components.count >= 3 else { return }

        let courseId: Course.ID = String(components[1])

        guard let content = try? await learnKit.getContent(for: String(components[2]), in: courseId) else { return }

        switch content.handler {
            case .contentItem, .contentFolder(isBbPage: _), .contentLesson:
                router.navigate(to: .route(.myStudies(.module(courseId, .content(content.id)))))
            case .assignment(gradeColumn: let gradeColumnId, isGroup: _), .testLink(target: _, gradeColumn: let gradeColumnId):
                router.navigate(to: .route(.myStudies(.module(courseId, .grades(gradeColumnId)))))
            case .externalLink(let url):
                if #available(iOS 26, macOS 26, *) {
                    openURL(url, prefersInApp: true)
                } else {
                    openURL(url)
                }
            case .ltiLink(let url, parameters: let customParams):
                if var components = URLComponents(string: url.absoluteString) {
                    components.queryItems = customParams.map {
                        URLQueryItem(name: $0, value: $1)
                    }

                    if #available(iOS 26, macOS 26, *) {
                        openURL(url, prefersInApp: true)
                    } else {
                        openURL(url)
                    }
                } else {
                    return
                }
            default:
                if !content.links.isEmpty {
                    let resolvedUrl = URL(string: "https://studentcentral.brighton.ac.uk")!.appending(path: content.links.first!.href)
                    if #available(iOS 26, macOS 26, *) {
                        openURL(resolvedUrl, prefersInApp: true)
                    } else {
                        openURL(resolvedUrl)
                    }
                } else {
                    return
                }
        }
    }
}

public extension View {
    func onContinueRouterUserActivities(learnKit: LearnKitService) -> some View {
        modifier(OnContinueRouterUserActivitiesViewModifier(learnKit: learnKit))
    }
}
