//
//  SearchView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import CoreSpotlight
import Router
import LearnKit

struct SearchView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    @Environment(Router.self) private var router: Router
    @Environment(SearchManager.self) private var searchManager: SearchManager
    @Environment(\.learnKitService) private var learnKit

    @State private var searchResults: [CSUserQuery.Item] = []
    @State private var searchSuggestions: [CSUserQuery.Suggestion] = []

    @State private var showNavigationError: Bool = false
    @State private var invalidItemTitle: String? = nil

    @State private var currentNavTask: Task<Void, any Error>? = nil

    var body: some View {
        @Bindable var searchManager = searchManager
        
        root
            .myBrightonBackground()
            .navigationTitle("Search")
    #if !os(macOS)
            .searchable(
                text: $searchManager.searchTerm,
                isPresented: $searchManager.isSearching,
                prompt: searchPrompt
            )
            .searchSuggestions {
                ForEach(searchSuggestions.sorted(by: { $0.suggestion.compare(byRank: $1.suggestion) == .orderedDescending }), id: \.id) { suggestion in
                    Text(suggestion.suggestion.localizedAttributedSuggestion)
                        .searchCompletion(String(suggestion.suggestion.localizedAttributedSuggestion.characters))
                        .onTapGesture {
                            searchManager.currentQuery.userEngaged(suggestion, visibleSuggestions: searchSuggestions, interaction: .select)
                        }
                }
            }
    #endif
            .onAppear {
                CSUserQuery.prepare()
            }
            .task(id: searchManager.searchTerm) {
                guard !searchManager.searchTerm.isEmpty else {
                    searchSuggestions = []
                    searchResults = []
                    return
                }

                do {
                    try await Task.sleep(for: .seconds(0.3))

                    await searchManager.requestUserQueryUpdate()
                    searchSuggestions = []
                    searchResults = []
                    for try await response in searchManager.currentQuery.responses {
                        switch response {
                            case .item(let item):
                                searchResults.append(item)
                                break
                            case .suggestion(let suggestion):
                                searchSuggestions.append(suggestion)
                                break
                            @unknown default:
                                break
                        }
                    }
                } catch {
                    print(error)
                }
            }
            .alert("Cannot navigate to \(invalidItemTitle ?? "Unknown")", isPresented: $showNavigationError) {
                Button("OK") {
                    showNavigationError = false
                    invalidItemTitle = nil
                }
            }
    }

    @ViewBuilder
    private var root: some View {
        @Bindable var searchManager = searchManager

        if searchManager.searchTerm.isEmpty {
            // TODO: Keep a history of previous search results
            VStack {
                
            }
        } else if searchResults.isEmpty {
            VStack {
                ContentUnavailableView.search
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(searchResults, id: \.id) { result in
                    Button {
                        if let currentNavTask {
                            currentNavTask.cancel()
                        }

                        currentNavTask = Task {
                            defer { currentNavTask = nil }

                            await performNavigation(result)
                        }
                    } label: {
                        SearchItemRowView(item: result.item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        #if os(macOS)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 16)
                        #endif
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    #if os(iOS)
                    .listRowSpacing(8)
                    #endif
                    .listRowBackground(
                        ContainerRelativeShape()
                            .foregroundStyle(.brightonBackground)
                            .contraCard()
                            .padding(3)
                    )
                }
            }
            .scrollContentBackground(.hidden)
            #if os(macOS)
            .contentMargins(16, for: .scrollContent)
            #endif
        }
    }

    // MARK: Localisation
    private let searchPrompt: String = .init(
        localized: "prompt.search",
        defaultValue: "Courses, Content, Societies",
        table: "Search",
        comment: "Represents different things that a user can search for."
    )

    private func performNavigation(_ result: CSUserQuery.Item) async {
        searchManager.currentQuery.userEngaged(result, visibleItems: searchResults, interaction: .select)
        if result.item.uniqueIdentifier.starts(with: "content/") {
            let components = result.item.uniqueIdentifier.split(separator: "/")
            guard components.count >= 3 else {
                invalidItemTitle = result.item.attributeSet.title ?? "Unknown"
                showNavigationError = true
                return
            }

            let courseId: Course.ID = String(components[1])

            guard let content = try? await learnKit.getContent(for: String(components[2]), in: courseId) else {
                invalidItemTitle = result.item.attributeSet.title ?? "Unknown"
                showNavigationError = true
                return
            }

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
                        invalidItemTitle = result.item.attributeSet.title ?? "Unknown"
                        showNavigationError = true
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
                        invalidItemTitle = result.item.attributeSet.title ?? "Unknown"
                        showNavigationError = true
                        return
                    }
            }
        } else if let route = Navigation.Route(spotlightIdentifier: result.item.uniqueIdentifier) {
            router.navigate(to: .route(route))
        } else {
            invalidItemTitle = result.item.attributeSet.title ?? "Unknown"
            showNavigationError = true
        }
    }
}

#Preview(traits: .environmentObjects) {
    TabView {
        Tab(role: .search) {
            NavigationStack {
                SearchView()
            }
        }
    }
}
