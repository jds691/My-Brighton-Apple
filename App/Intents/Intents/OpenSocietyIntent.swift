//
//  OpenSocietyIntent.swift
//  My Brighton
//
//  Created by Neo Salmon on 18/08/2025.
//

#if ENABLE_BSU
import AppIntents
import Router

struct OpenSocietyIntent: AppIntent, OpenIntent {

    static let title: LocalizedStringResource = "Open Society"
    static let description: IntentDescription? = IntentDescription("Opens the provided society", categoryName: "Societies")

    @Parameter(title: "Society", description: "Society to open")
    var target: SocietyEntity

    @Dependency
    private var router: Router

    func perform() async throws -> some IntentResult {
        await router.navigate(to: .route(.bsu))
        //await router.appendToNavigationPath(target.id)
        return .result()
    }
}
#endif
