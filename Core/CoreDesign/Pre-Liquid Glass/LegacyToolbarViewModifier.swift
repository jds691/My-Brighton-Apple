//
//  LegacyToolbarViewModifier.swift
//  My Brighton
//
//  Created by Neo Salmon on 23/10/2025.
//

import SwiftUI

// TODO: Make all buttons the same size
struct LegacyToolbarViewModifier<ToolbarContent: View>: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    private var legacyToolbarRequiresTopPadding: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    private var legacyToolbarIgnoresEdges: Edge.Set {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.top]
        }
        #endif

        return []
    }

    let isVisible: Bool
    let showsBackButton: Bool
    let toolbarContent: ToolbarContent

    init(visible: Bool, showsBackButton: Bool, toolbarContent: ToolbarContent) {
        self.isVisible = visible
        self.showsBackButton = showsBackButton
        self.toolbarContent = toolbarContent
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isVisible {
                    HStack {
                        if showsBackButton {
                            Button {
                                dismiss()
                            } label: {
                                Label("Back", systemImage: "chevron.left")
                            }
                            .labelStyle(.titleAndIcon)
                        }

                        Spacer()

                        toolbarContent
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.floating)
                    .scenePadding(.horizontal)
                    // Correctly aligns the buttons to the floating tab bar on iPadOS
                    .padding(.top, legacyToolbarRequiresTopPadding ? 32 : 0)
                    .transition(.opacity)
                    .ignoresSafeArea(edges: legacyToolbarIgnoresEdges)
                }
            }
    }
}

extension View {
    public func legacyToolbar(visible: Bool = true, showBackButton: Bool = false, @ViewBuilder _ toolbarContent: @escaping () -> some View) -> some View {
        modifier(LegacyToolbarViewModifier(visible: visible, showsBackButton: showBackButton, toolbarContent: toolbarContent()))
    }
}
