//
//  SocietyEntityQuery.swift
//  My Brighton
//
//  Created by Neo Salmon on 18/08/2025.
//

#if ENABLE_BSU
import AppIntents

struct SocietyEntityQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [Entity] {
        return try await getSocieties().filter { $0.name.contains(string) }
    }

    func entities(for identifiers: [Society.ID]) async throws -> [Entity] {
        return try await getSocieties().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [Entity] {
        // TODO: Return the users societies that they are a member of
        return try await getSocieties()
    }

    typealias Entity = SocietyEntity

    private func getSocieties() async throws -> [SocietyEntity] {
        let json = """
{
 "societyemail": "brightonvideogamingsociety",
 "society_created_date": "2025",
 "description": "The official Brighton Video Gaming Society, where players who enjoy casual games can come together to socialise!",
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
   "sortindex": -1000001,
   "array": [],
   "sectionname": "Memberships"
  },
  {
   "sortindex": -1000000,
   "array": [
    {
     "sortindex": 1757690134,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_13.png",
     "subtitle": "Vice President",
     "id": "25680",
     "title": "Neo Salmon",
     "iscircle": true
    },
    {
     "sortindex": 1757690106,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_12.png",
     "subtitle": "President",
     "id": "25679",
     "title": "Alexander Lehane",
     "iscircle": true
    },
    {
     "sortindex": 1757690202,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_14.png",
     "subtitle": "VP online social ",
     "id": "25681",
     "title": "Billy Putland",
     "iscircle": true
    },
    {
     "sortindex": 1757690242,
     "image": "https://portal.hellorubric.com/assets/img/patterns/pattern_15.png",
     "subtitle": "VP Welfare ",
     "id": "25682",
     "title": "Sammy Benotman ",
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
 "discordurl": "https://discord.gg/syBwJBuHqZ",
 "uniname": "University of Brighton",
 "logo_uploaded": "https://cachedresources.hellorubric.com/uploaded_assets/7b00a831-06c2-4924-b6be-7b4c74f30f49.png",
 "instagramurl": "https://www.instagram.com/bsuvideogamingsoc",
 "society_banner_image": "https://cachedresources.hellorubric.com/uploaded_assets/c5735a3b-cdbf-47d4-9405-66c163953be4.png",
 "success": true,
 "societyid": 13274,
 "name": "Brighton Videogame Society",
 "emaildomain": "gmail.com"
}
"""
        let society = try JSONDecoder().decode(Society.self, from: json.data(using: .utf8)!)

        return await [SocietyEntity(from: society)]
    }
}
#endif
