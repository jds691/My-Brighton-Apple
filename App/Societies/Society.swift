//
//  Society.swift
//  My Brighton
//
//  Created by Neo Salmon on 18/08/2025.
//

#if ENABLE_BSU
import Foundation
import SwiftData

nonisolated
public struct Society: Identifiable, Hashable, Sendable, Codable {
    public var email: String
    public var emailDomain: String

    public var universityLogoURL: URL?
    public var universityName: String
    public var logoURL: URL?
    public var bannerImageURL: URL

    public var id: Int
    public var creationYear: String
    public var name: String
    public var description: String?
    public var showRatings: Bool
    public var allowExternalBioLinks: Bool

    public var discordURL: URL?
    public var instagramURL: URL?

    enum CodingKeys: String, CodingKey {
        case email = "societyemail"
        case emailDomain = "emaildomain"

        case universityLogoURL = "unilogo"
        case universityName = "uniname"

        case logoURL = "logo_uploaded"
        case bannerImageURL = "society_banner_image"

        case id = "societyid"
        case creationYear = "society_created_date"
        case name
        case description
        case showRatings = "showRatingsReviews"
        case allowExternalBioLinks = "allowExternalBioLinks"

        case discordURL = "discordurl"
        case instagramURL = "instagramurl"
    }
}
#endif
