//
//  DisplayRepresentationProvider.swift
//  My Brighton
//
//  Created by Neo Salmon on 09/04/2026.
//

import AppIntents

public protocol DisplayRepresentationProvider<Entity>: Sendable {
    associatedtype Entity: AppEntity

    func representation(for entity: Entity) -> DisplayRepresentation?
}
