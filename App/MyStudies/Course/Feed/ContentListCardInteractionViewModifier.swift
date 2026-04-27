//
//  ContentListCardInteractionViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/04/2026.
//

import SwiftUI
import LearnKit
import Router

struct ContentListCardInteractionViewModifier: ViewModifier {
    @Environment(\.openURL) private var openURL

    let content: LearnKit.Content

    init(_ content: Content) {
        self.content = content
    }

    func body(content: Self.Content) -> some View {
        switch self.content.handler {
            case .contentItem, .contentFolder(isBbPage: _), .contentLesson:
                NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.content(self.content.id)) {
                    content
                }
                .buttonStyle(.plain)
            case .assignment(gradeColumn: let gradeColumnId, isGroup: _), .testLink(target: _, gradeColumn: let gradeColumnId):
                NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.grades(gradeColumnId)) {
                    content
                }
                .buttonStyle(.plain)
            case .externalLink(let url):
                Button {
                    if #available(iOS 26, macOS 26, *) {
                        openURL(url, prefersInApp: true)
                    } else {
                        openURL(url)
                    }
                } label: {
                    content
                }
                .buttonStyle(.plain)
            case .ltiLink(let url, parameters: let customParams):
                Button {
                    if var components = URLComponents(string: url.absoluteString) {
                        components.queryItems = customParams.map {
                            URLQueryItem(name: $0, value: $1)
                        }

                        if #available(iOS 26, macOS 26, *) {
                            openURL(url, prefersInApp: true)
                        } else {
                            openURL(url)
                        }
                    }
                } label: {
                    content
                }
                .buttonStyle(.plain)
            default:
                if !self.content.links.isEmpty {
#if DEBUG
                    VStack(alignment: .leading) {
                        Button {
                            let resolvedUrl = URL(string: "https://studentcentral.brighton.ac.uk")!.appending(path: self.content.links.first!.href)
                            if #available(iOS 26, macOS 26, *) {
                                openURL(resolvedUrl, prefersInApp: true)
                            } else {
                                openURL(resolvedUrl)
                            }
                        } label: {
                            content
                        }
                        .buttonStyle(.plain)

                        Text(verbatim: "No interaction available for `\(self.content.handler)`")
                            .foregroundStyle(.red)
                    }
#else
                    Button {
                        let resolvedUrl = URL(string: "https://studentcentral.brighton.ac.uk")!.appending(path: self.content.links.first!.href)
                        if #available(iOS 26, macOS 26, *) {
                            openURL(resolvedUrl, prefersInApp: true)
                        } else {
                            openURL(resolvedUrl)
                        }
                    } label: {
                        content
                    }
                    .buttonStyle(.plain)
#endif
                } else {
#if DEBUG
                    VStack(alignment: .leading) {
                        content
                        Text(verbatim: "No interaction available for `\(self.content.handler)`")
                            .foregroundStyle(.red)
                    }
#else
                    EmptyView()
#endif
                }
        }
    }
}
