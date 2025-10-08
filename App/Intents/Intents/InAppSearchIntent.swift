//
//  InAppSearchIntent.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/06/2025.
//

import Foundation
import AppIntents
import Router

@AppIntent(schema: .system.search)
struct InAppSearchIntent: AppIntent, ShowInAppSearchResultsIntent {
    static let isAssistantOnly: Bool = true
    
    static let searchScopes: [StringSearchScope] = [.general]
    var criteria: StringSearchCriteria
    
    @AppDependency
    private var router: Router
    @AppDependency
    private var searchManager: SearchManager
    
    func perform() async throws -> some IntentResult {
        let searchString = criteria.term
        
        await router.navigate(to: .route(.search))
        await searchManager.search(for: searchString)
        
        return .result()
    }
}
