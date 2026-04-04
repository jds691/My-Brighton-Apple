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
            .popover(isPresented: $showEditor) {
                HomeCustomisationEditView(customisations: $customisations)
                    .interactiveDismissDisabled()
            }
        #elseif os(iOS)
        if hSizeClass == .compact {
            content
                .sheet(isPresented: $showEditor) {
                    HomeCustomisationEditView(customisations: $customisations)
                        .presentationBackgroundInteraction(.enabled)
                        .presentationDetents([.fraction(0.72)])
                        .interactiveDismissDisabled()
                }
        } else {
            content
                .popover(isPresented: $showEditor) {
                    HomeCustomisationEditView(customisations: $customisations)
                        .interactiveDismissDisabled()
                }
        }
        #endif
    }
}
