//
//  TimetableService+Previews.swift
//  My Brighton
//
//  Created by Neo Salmon on 29/08/2025.
//

import SwiftUI
import Timetable

public extension EnvironmentValues {
    @Entry var timetableService: TimetableService = TimetableService(notifier: nil)
}

struct TimetableServicePreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> TimetableService {
        return TimetableService(from: NSDataAsset(name: "Timetable")!.data)
    }

    func body(content: Self.Content, context: TimetableService) -> some View {
        content
            .environment(\.timetableService, context)
    }
}

extension PreviewTrait {
    static var timetableService: PreviewTrait<Preview.ViewTraits> {
        .init(
            .modifier(TimetableServicePreviewModifier())
        )
    }
}
