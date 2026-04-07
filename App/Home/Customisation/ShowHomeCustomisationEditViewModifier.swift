//
//  ShowHomeCustomisationEditViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import Foundation
import SwiftUI
import CustomisationKit

struct ShowHomeCustomisationEditViewModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @Binding var customisations: HomeCustomisation
    @Binding var showEditor: Bool

    init(customisations: Binding<HomeCustomisation>, showEditor: Binding<Bool>) {
        self._customisations = customisations
        self._showEditor = showEditor
    }

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .sheet(isPresented: $showEditor) {
                HomeCustomisationEditView(customisations: $customisations)
                    .scenePadding()
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
            }
        #elseif os(iOS)
        content
            .sheet(isPresented: $showEditor) {
                HomeCustomisationEditView(customisations: $customisations)
                    .presentationBackgroundInteraction(.enabled)
                // When running on an iPad in landspace is doesn't match up without changing the value
                    .presentationDetents([.fraction(0.68)])
                    .interactiveDismissDisabled()
            }
        #endif
    }
}
