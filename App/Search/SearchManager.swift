//
//  SearchManager.swift
//  My Brighton
//
//  Created by Neo Salmon on 16/06/2025.
//

import SwiftUI
import CoreSpotlight

@Observable
final class SearchManager {
    public static let shared = SearchManager()

    @ObservationIgnored
    private var queryDelayTimer: Timer?
    public private(set) var currentQuery: CSUserQuery
    private var currentSearchTerm: String = ""
    public var searchTerm: String {
        get { return currentSearchTerm }
        set {
            currentSearchTerm = newValue
        }
    }
    private var isSearchFocused: Bool = false
    public var isSearching: Bool {
        get { return isSearchFocused }
        set {
            isSearchFocused = newValue

            if newValue {
                CSUserQuery.prepare()
            }
        }
    }

    init() {
        self.currentQuery = .init(userQueryString: nil, userQueryContext: nil)
    }

    public func search(for term: String) {
        searchTerm = term
        isSearching = true
        currentQuery = CSUserQuery(userQueryString: term, userQueryContext: createCSUserQueryContext())
    }
    
    public func focusSearchField() {
        isSearching = true
    }

    public func requestUserQueryUpdate() async {
        currentQuery = CSUserQuery(userQueryString: createQueryString(for: searchTerm), userQueryContext: createCSUserQueryContext())
    }

    private func createQueryString(for term: String) -> String {
        // TODO: Add support for Spotlight meta statements
        // https://developer.apple.com/documentation/corespotlight/searching-for-information-in-your-app#Create-a-query-string-for-your-search

        //return "title == \"*\(term)*\"c"
        return term
    }

    nonisolated
    private func createCSUserQueryContext() -> CSUserQueryContext {
        let context = CSUserQueryContext()
        context.maxSuggestionCount = 5
        context.enableRankedResults = true
        context.fetchAttributes = [
            "title",
            "displayName",
            "contentDescription",
            "thumbnailData",
            "thumbnailURL",
            "darkThumbnailURL"
        ]

        return context
    }
}
