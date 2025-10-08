//
//  SocietiesService.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/09/2025.
//

#if ENABLE_BSU
import Foundation

// TODO: Rubric does not indicate when a society was last changed, it may be smart to only do a partial index here and request the full information each time it's needed
// Only resorting to the cache if the program does not have an internet connection

// TODO: getUnifiedHomeScreen might be a useful call to make for getting popular societies and events

nonisolated
public final class SocietiesService: Sendable {
    private static let apiURL: URL = URL(string: "https://api.hellorubric.com")!
    private let cache: SocietyCache = SocietyCache()

    public func refreshSocietiesIfNeeded() async throws {
        var requestDetails = GetUnifiedSearchEndpointDetails(
            firstCall: true,
            sortType: "itemName",
            desiredType: "societies",
            limit: 0,
            offset: 0,
            sortDirection: "desc",
            searchQuery: "",
            eventsPeriodFilter: "All",
            countryCode: "GB",
            state: "South+East",
            selectedUniversityId: 74,
            currentUrl: URL(string: "https://campus.hellorubric.com/search?type=societies")!,
            device: "web_portal",
            version: 4
        )

        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "endpoint", value: "getUnifiedSearch"),
            URLQueryItem(name: "details", value: String(decoding: try JSONEncoder().encode(requestDetails), as: UTF8.self))
        ]

        var request = URLRequest(url: Self.apiURL)

        request.httpMethod = "POST"
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let reponse = try await URLSession.shared.data(for: request)
        let responseBody = try JSONDecoder().decode(GetUnifiedSearchEndpointResponse.self, from: reponse.0)

        // TODO: Check with local cache, if count hasn't changed do not request remaining societies
        if await responseBody.totalItemCount == cache.indexedSocietyCount() { return }

        requestDetails.firstCall = false
        requestDetails.limit = responseBody.totalItemCount
        // TODO: Check if applying an offset of the current cached society count is feasible

        requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "endpoint", value: "getUnifiedSearch"),
            URLQueryItem(name: "details", value: String(decoding: try JSONEncoder().encode(requestDetails), as: UTF8.self))
        ]

        request = URLRequest(url: Self.apiURL)
        request.httpMethod = "POST"
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let allSocietiesResponse = try await URLSession.shared.data(for: request)
        let allSocietiesResponseBody = try JSONDecoder().decode(GetUnifiedSearchEndpointResponse.self, from: allSocietiesResponse.0)
    }
}
#endif
