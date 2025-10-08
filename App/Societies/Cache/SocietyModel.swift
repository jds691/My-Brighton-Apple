//
//  SocietyModel.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/09/2025.
//

#if ENABLE_BSU
import Foundation
import SwiftData

@Model
nonisolated
public class SocietyModel: Identifiable {
    public var email: String
    public var emailDomain: String

    public var universityLogoURL: URL?
    public var universityName: String
    public var logoURL: URL?
    public var bannerImageURL: URL

    @Attribute(.unique)
    public var id: Int
    public var creationYear: String
    public var name: String
    public var showRatings: Bool
    public var allowExternalBioLinks: Bool

    public init(from society: Society) {
        self.email = society.email
        self.emailDomain = society.emailDomain
        self.universityLogoURL = society.universityLogoURL
        self.universityName = society.universityName
        self.logoURL = society.logoURL
        self.bannerImageURL = society.bannerImageURL
        self.id = society.id
        self.creationYear = society.creationYear
        self.name = society.name
        self.showRatings = society.showRatings
        self.allowExternalBioLinks = society.allowExternalBioLinks
    }
}
#endif
