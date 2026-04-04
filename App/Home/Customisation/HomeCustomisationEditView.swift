//
//  HomeCustomisationEditView.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import Foundation
import SwiftUI
import CustomisationKit

struct HomeCustomisationEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var originalCustomisations: HomeCustomisation = HomeCustomisation()
    @State private var tempCustomisations: HomeCustomisation = HomeCustomisation()

    @Binding var customisations: HomeCustomisation

    @State private var customName: String = ""

    @State private var textColor: Color = .white

    var body: some View {
        NavigationStack {
            Form {
                Section("Nickname") {
                    TextField("Nickname", text: $customName)
                }
                .onChange(of: customName) {
                    if customName.trimmingCharacters(in: .whitespaces).isEmpty {
                        customisations.displayNameOverride = nil
                    } else {
                        customisations.displayNameOverride = customName
                    }
                }

                CustomisationBackgroundEditor(background: $customisations.background)
                CustomisationTextEffectsEditor(textColor: $textColor, fontDesign: $customisations.fontDesign, textAlignment: .constant(.bottomLeading), textEffects: $customisations.textEffects)
                    .enabledEffects([
                        .textColor,
                        .fontDesign,
                        .textEffects
                    ])
                    .onChange(of: textColor) {
                        customisations.textColor = .fromColor(textColor)
                    }
            }
            .navigationTitle("Customise")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()

                        customisations = originalCustomisations
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .labelStyle(.designSystemAware)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()

                        saveChangesToOriginalCustomisations()
                        customisations = originalCustomisations
                    } label: {
                        Label("Confirm", systemImage: "checkmark")
                    }
                    .labelStyle(.designSystemAware)
                }
            }
            .onAppear {
                originalCustomisations = customisations

                tempCustomisations.displayNameOverride = originalCustomisations.displayNameOverride
                tempCustomisations.background = originalCustomisations.background
                tempCustomisations.fontDesign = originalCustomisations.fontDesign
                tempCustomisations.textColor = originalCustomisations.textColor
                tempCustomisations.textEffects = originalCustomisations.textEffects

                customisations = tempCustomisations
            }
        }
    }

    private func saveChangesToOriginalCustomisations() {
        originalCustomisations.displayNameOverride = customisations.displayNameOverride
        originalCustomisations.background = customisations.background
        originalCustomisations.fontDesign = customisations.fontDesign
        originalCustomisations.textColor = customisations.textColor
        originalCustomisations.textEffects = customisations.textEffects
    }
}
