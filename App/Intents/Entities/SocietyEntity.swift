//
//  SocietyEntity.swift
//  My Brighton
//
//  Created by Neo Salmon on 18/08/2025.
//

#if ENABLE_BSU
import AppIntents

struct SocietyEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Society")
    }

    var displayRepresentation: DisplayRepresentation {
        if let iconImageData {
            return .init(title: "\(name)", image: .init(data: iconImageData, displayStyle: .circular))
        } else {
            return .init(title: "\(name)", image: .init(named: "bsu.logo", isTemplate: true))
        }
    }

    static let defaultQuery = SocietyEntityQuery()

    @Property(title: "ID")
    var id: Society.ID

    @Property(title: "Name")
    var name: String
    //@Property(title: "Icon Image")
    var iconImageData: Data?

    init(from society: Society) async {
        self.id = society.id
        self.name = society.name
        if let logoURL = society.logoURL {
            do {
                self.iconImageData = try await URLSession(configuration: .default).data(from: logoURL).0
            } catch {
                self.iconImageData = nil
            }
        } else {
            self.iconImageData = nil
        }
    }
}

nonisolated
extension SocietyEntity: URLRepresentableEntity {
    static var urlRepresentation: URLRepresentation {
        "https://campus.hellorubric.com/?s=\(.id)#"
    }
}

nonisolated
extension SocietyEntity: IndexedEntity {

}
#endif
