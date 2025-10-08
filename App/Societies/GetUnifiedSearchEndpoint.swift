//
//  GetUnifiedSearchEndpoint.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/09/2025.
//

#if ENABLE_BSU
import Foundation

nonisolated
struct GetUnifiedSearchEndpointDetails: Encodable {
    var firstCall: Bool
    var sortType: String
    var desiredType: String
    var limit: Int
    var offset: Int
    var sortDirection: String
    var searchQuery: String
    var eventsPeriodFilter: String
    var countryCode: String
    var state: String
    var selectedUniversityId: Int
    var currentUrl: URL
    var device: String
    var version: Int

    init(firstCall: Bool, sortType: String, desiredType: String, limit: Int, offset: Int, sortDirection: String, searchQuery: String, eventsPeriodFilter: String, countryCode: String, state: String, selectedUniversityId: Int, currentUrl: URL, device: String, version: Int) {
        self.firstCall = firstCall
        self.sortType = sortType
        self.desiredType = desiredType
        self.limit = limit
        self.offset = offset
        self.sortDirection = sortDirection
        self.searchQuery = searchQuery
        self.eventsPeriodFilter = eventsPeriodFilter
        self.countryCode = countryCode
        self.state = state
        self.selectedUniversityId = selectedUniversityId
        self.currentUrl = currentUrl
        self.device = device
        self.version = version
    }
}


nonisolated
struct GetUnifiedSearchEndpointResponse: Decodable {
    var selectedUniversityId: String
    var societyEventTypes: [String]
    var selectedEventsPeriodFilter: String
    var countries: [Country]
    var totalItemCount: Int
    var sortDirection: String
    var societyClubTypes: [String]
    var universities: [University]
    var sortType: String
    var selectedCountryCode: String
    var success: Bool
    var results: [Society]
    var selectedState: String

    enum CodingKeys: String, CodingKey {
        case selectedUniversityId
        case societyEventTypes = "society_event_types"
        case selectedEventsPeriodFilter
        case countries
        case totalItemCount
        case sortDirection
        case societyClubTypes = "society_club_types"
        case universities
        case sortType
        case selectedCountryCode
        case success
        case results
        case selectedState
    }

    struct Country: Decodable {
        var countryCode: String
        var country: String
        var state: String
        var flagURL: URL

        enum CodingKeys: String, CodingKey {
            case countryCode = "country_code"
            case country
            case state
            case flagURL = "flag_url"
        }
    }

    struct University: Decodable {
        var country: String
        var logoURLString: String
        var name: String
        var id: Int
        var state: String
        var shortName: String

        enum CodingKeys: String, CodingKey {
            case country
            case logoURLString = "logo_url"
            case name
            case id
            case state
            case shortName = "shortname"
        }
    }

    struct Society: Decodable {
        var logoURL: URL
        var universityName: String
        var destination: String
        var id: String
        var name: String

        enum CodingKeys: String, CodingKey {
            case logoURL = "image"
            case universityName = "subtitle"
            case destination
            case id = "societyid"
            case name = "title"
        }
    }
}
#endif
