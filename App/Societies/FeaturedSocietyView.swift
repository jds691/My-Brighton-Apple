//
//  FeaturedSocietyView.swift
//  My Brighton
//
//  Created by Neo Salmon on 08/09/2025.
//

#if ENABLE_BSU
import Foundation
import SwiftUI

struct FeaturedSocietyView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var society: Society

    init(_ society: Society) {
        self.society = society
    }

    var body: some View {
        if hSizeClass == .compact {
            compact
        } else {
            expanded
        }
    }

    @ViewBuilder
    private var image: some View {
        AsyncImage(url: society.bannerImageURL) { image in
            if #available(iOS 26, macOS 26, *) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .backgroundExtensionEffect()
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            }
        } placeholder: {
            // TODONT: Replace with a default BSU graphic
            if #available(iOS 26, macOS 26, *) {
                Rectangle()
                    .backgroundExtensionEffect()
            } else {
                Rectangle()
            }
        }
    }

    @ViewBuilder
    private var expanded: some View {
        image
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 8) {
                    Group {
                        if let logoURL = society.logoURL {
                            AsyncImage(url: logoURL) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Image(.societyLogoPlaceholder)
                                    .resizable()
                            }
                        } else {
                            Image(.societyLogoPlaceholder)
                                .resizable()
                        }
                    }
                    .frame(width: 128, height: 128)
                    .padding(3)
                    .overlay {
                        Circle()
                            .strokeBorder(lineWidth: 3, antialiased: true)
                    }
                    .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(society.name)
                            .font(.largeTitle.bold())
                        if let description = society.description {
                            Text(description)
                                .lineLimit(3)
                        }
                    }
                    .foregroundStyle(.white)
                }
                .padding(16)
            }
    }

    @ViewBuilder
    private var compact: some View {
        image
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    Group {
                        if let logoURL = society.logoURL {
                            AsyncImage(url: logoURL) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Image(.societyLogoPlaceholder)
                                    .resizable()
                            }
                        } else {
                            Image(.societyLogoPlaceholder)
                                .resizable()
                        }
                    }
                    .frame(width: 128, height: 128)
                    .padding(3)
                    .overlay {
                        Circle()
                            .strokeBorder(lineWidth: 3, antialiased: true)
                    }
                    .clipShape(Circle())
                    VStack(spacing: 4) {
                        Text(society.name)
                            .font(.largeTitle.bold())
                        if let description = society.description {
                            Text(description)
                                .lineLimit(3)
                        }
                    }
                    .foregroundStyle(.white)
                }
                .padding(16)
            }
    }
}

#Preview("No Description") {
    let society: Society = {
        let json = """
{
 "societyemail": "m.reilly1",
 "society_created_date": "2025",
 "showRatingsReviews": true,
 "allowExternalBioLinks": true,
 "sections": [
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Events"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Merchandise"
  },
  {
   "sortindex": -1755744229,
   "array": [{
    "sortindex": 1755744229,
    "image": "https://cachedresources.hellorubric.com/uploaded_assets/a50e47e9-a159-4f66-8ec1-c0857dfc23f7.png",
    "subtitle": "Please click Join us to follow the link and purchase the membership to our club",
    "destination": "https://sport.brighton.ac.uk/programmes/student-clubs",
    "externallink": true,
    "title": "Club Membership",
    "info": "N/A "
   }],
   "sectionname": "Memberships"
  },
  {
   "sortindex": -1000000,
   "array": [
    {
     "sortindex": 1755487772,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_13.png",
     "subtitle": "President/VP/ treasurer",
     "id": "20082",
     "title": "Cinar Erkol",
     "iscircle": true
    },
    {
     "sortindex": 1755487773,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_14.png",
     "subtitle": "Wellbeing Officer",
     "id": "20083",
     "title": "Olivia Clarke",
     "iscircle": true
    },
    {
     "sortindex": 1755487776,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_15.png",
     "subtitle": "Social Media Secretary",
     "id": "20084",
     "title": "Harry Baker",
     "iscircle": true
    }
   ],
   "sectionname": "Committee"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "News"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Deals"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Reviews"
  }
 ],
 "uniname": "University of Brighton",
 "unilogo": "https://resources.hellorubric.com/images/university_logos/74.jpg",
 "logo_uploaded": "https://cachedresources.hellorubric.com/uploaded_assets/514601df-4d1e-4b6d-9995-877a83196bcc.png",
 "society_banner_image": "https://cachedresources.hellorubric.com/uploaded_assets/867d5305-e8e0-4fac-9dbf-c18003f9335d.png",
 "success": true,
 "societyid": 13002,
 "name": "Swimming",
 "emaildomain": "uni.brighton.ac.uk"
}
"""
        return try! JSONDecoder().decode(Society.self, from: json.data(using: .utf8)!)
    }()

    ScrollView {
        FeaturedSocietyView(society)
            .flexibleHeaderContent(bodyRatio: 2)
    }
    .flexibleHeaderScrollView()
    #if os(iOS)
    .ignoresSafeArea(edges: .top)
    #endif
}

#Preview("Description") {
    let society: Society = {
        let json = """
{
 "societyemail": "z.stubbs1",
 "society_created_date": "2025",
 "description": "We started The Grown-Up Club because we know how different university can feel as mature and parent students. Most events are aimed at younger students, and it can be hard to find others balancing study with work, family, or life experience. TGUC is a welcoming space to meet like-minded people, share support, and enjoy uni life together without the pressure to fit in with the fresher crowd. ",
 "showRatingsReviews": true,
 "allowExternalBioLinks": true,
 "sections": [
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Events"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Merchandise"
  },
  {
   "sortindex": -1756199887,
   "array": [{
    "sortindex": 1756199887,
    "image": "https://cachedresources.hellorubric.com/uploaded_assets/27e704d7-396f-476d-80a8-e12888517640.png",
    "subtitle": "Join our Discord to sign up, meet other members, and stay updated on our events!",
    "destination": "https://discord.gg/dAhq4Vz3",
    "externallink": true,
    "title": "Join us on Discord!",
    "info": "Free"
   }],
   "sectionname": "Memberships"
  },
  {
   "sortindex": -1000000,
   "array": [
    {
     "sortindex": 1756368703,
     "image": "https://cachedresources.hellorubric.com/uploaded_assets/31a9daf7-b53a-4742-acc2-0a87ee1fcfc4.png",
     "subtitle": "President",
     "id": "20815",
     "title": "Zoe Stubbs",
     "iscircle": true
    },
    {
     "sortindex": 1756392366,
     "image": "https://cachedresources.hellorubric.com/uploaded_assets/de776ad9-7e8d-4dbb-b901-59526af76b15.png",
     "subtitle": "Treasurer",
     "id": "20817",
     "title": "Laurie Marks",
     "iscircle": true
    },
    {
     "sortindex": 1756368530,
     "image": "https://cachedresources.hellorubric.com/uploaded_assets/3ff23913-1f89-42cf-b8cc-1ee461be723f.png",
     "subtitle": "Social Media Marketing Assistant ",
     "id": "20821",
     "title": "Storm",
     "iscircle": true
    },
    {
     "sortindex": 1756375584,
     "image": "https://cachedresources.hellorubric.com/uploaded_assets/106580e6-9b4d-4f5e-9047-8c5adff7b8f4.png",
     "subtitle": "Secretary",
     "id": "21504",
     "title": "Cas",
     "iscircle": true
    },
    {
     "sortindex": 1756392516,
     "image": "https://cachedresources.hellorubric.com/uploaded_assets/6350faca-6cbe-4cb5-ac32-ad30baa6ad62.png",
     "subtitle": "Social Media Marketing Assistant ",
     "id": "21507",
     "title": "Gemma",
     "iscircle": true
    },
    {
     "sortindex": 1756392969,
     "image": "https://cachedresources.hellorubric.com/uploaded_assets/fb8cb434-2b9b-4c83-ab21-e4878b85eb68.png",
     "subtitle": "Vice President",
     "id": "21508",
     "title": "Jaelynn",
     "iscircle": true
    }
   ],
   "sectionname": "Committee"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "News"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Deals"
  },
  {
   "sortindex": -1000000,
   "array": [],
   "sectionname": "Reviews"
  }
 ],
 "discordurl": "https://discord.gg/dAhq4Vz3",
 "uniname": "University of Brighton",
 "logo_uploaded": "https://cachedresources.hellorubric.com/uploaded_assets/ebc1b054-e948-404d-aeca-67311cdf0bbd.png",
 "instagramurl": "https://www.instagram.com/thegrownupclubsociety_uob?igsh=NDhzcm5tbGhnNmdv",
 "society_banner_image": "https://resources.hellorubric.com/images/655aa6655e753_.png",
 "success": true,
 "societyid": 13078,
 "name": "The Grown-Up Club",
 "emaildomain": "uni.brighton.ac.uk"
}
"""
        return try! JSONDecoder().decode(Society.self, from: json.data(using: .utf8)!)
    }()

    ScrollView {
        FeaturedSocietyView(society)
            .flexibleHeaderContent(bodyRatio: 2)
    }
    .flexibleHeaderScrollView()
#if os(iOS)
    .ignoresSafeArea(edges: .top)
#endif
}
#endif
