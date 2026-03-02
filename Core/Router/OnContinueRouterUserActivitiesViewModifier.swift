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

    @Environment(Router.self) private var router

    public func body(content: Self.Content) -> some View {
        content
        // MARK: URL navigation
            .onOpenURL { url in
                router.navigate(from: url)
            }
        // MARK: System
            /*.onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                if let webpageURL = activity.webpageURL {
                    router.navigate(from: webpageURL)
                }
            }*/
            .onContinueUserActivity(CSSearchableItemActionType) { activity in
                guard let itemIdentifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }

                if let route = Navigation.Route(spotlightIdentifier: itemIdentifier) {
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
                        router.navigate(to: .route(.myStudies(.module(courseId, .announcements(nil)))))
#endif
                    } else {
                        router.navigate(to: .route(.myStudies(.module(courseId, .announcements(nil)))))
                    }
                } else {
                    // TODO: Handle system announcements
                }
            }
    }
}

public extension View {
    func onContinueRouterUserActivities() -> some View {
        modifier(OnContinueRouterUserActivitiesViewModifier())
    }
}
