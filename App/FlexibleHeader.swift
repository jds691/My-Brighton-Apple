//
//  FlexiHeader.swift
//  My Brighton
//
//  Created by Neo Salmon on 02/09/2025.
//
//  Modified based on Apple sample code, Landmarks: Building an app with Liquid Glass
//

import SwiftUI

extension EnvironmentValues {
    @Entry var viewSize: CGSize = .zero
}

@Observable private class FlexibleHeaderGeometry {
    var offset: CGFloat = 0
}

private struct FlexibleHeaderContentModifier: ViewModifier {
    @Environment(\.viewSize) private var viewSize
    @Environment(FlexibleHeaderGeometry.self) private var geometry

    private var bodyRatio: CGFloat

    init(bodyRatio: CGFloat = 2.5) {
        self.bodyRatio = bodyRatio
    }

    func body(content: Content) -> some View {
        let height = (viewSize.height / bodyRatio) - geometry.offset
        content
            .frame(height: height)
            .padding(.bottom, geometry.offset)
            .offset(y: geometry.offset)
    }
}

private struct FlexibleHeaderScrollViewModifier: ViewModifier {
    @State private var viewSize: CGSize = .zero
    @State private var geometry = FlexibleHeaderGeometry()

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                min(geometry.contentOffset.y + geometry.contentInsets.top, 0)
            } action: { _, offset in
                geometry.offset = offset
            }
            .onGeometryChange(for: CGSize.self) { geometry in
                geometry.size
            } action: {
                viewSize = $0
            }
            .environment(\.viewSize, viewSize)
            .environment(geometry)
    }
}

public extension ScrollView {
    @MainActor func flexibleHeaderScrollView() -> some View {
        modifier(FlexibleHeaderScrollViewModifier())
    }
}

public extension View {
    func flexibleHeaderContent(bodyRatio: CGFloat = 2.5) -> some View {
        modifier(FlexibleHeaderContentModifier(bodyRatio: bodyRatio))
    }
}
