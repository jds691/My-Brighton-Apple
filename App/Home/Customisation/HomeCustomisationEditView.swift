//
//  HomeCustomisationEditView.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import Foundation
import SwiftUI
import Router
import CustomisationKit
import PhotosUI

struct HomeCustomisationEditView: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var originalCustomisations: HomeCustomisation = HomeCustomisation()
    @State private var tempCustomisations: HomeCustomisation = HomeCustomisation()

    @Binding var customisations: HomeCustomisation

    @State private var showProfilePicturePicker: Bool = false
    @State private var selectedUserProfilePhoto: PhotosPickerItem? = nil

    @State private var customName: String = ""

    @State private var textColor: Color = .white

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Picture") {
                    HStack {
                        Text("Image")
                        Spacer()
                        Menu("Choose") {
                            Button {
                                showProfilePicturePicker = true
                            } label: {
                                Label("Photo Library", systemImage: "photo.on.rectangle")
                            }

                            Button {
                                //showProfilePicturePicker = true
                            } label: {
                                Label("Take Photo", systemImage: "camera")
                            }
                        }
                    }
                }
                .photosPicker(isPresented: $showProfilePicturePicker, selection: $selectedUserProfilePhoto, matching: .images)
                .task(id: selectedUserProfilePhoto) {
                    guard let selectedUserProfilePhoto else { return }

                    do {
                        let url = try await CustomisationService.storePhotosPickerProfilePictureItem(selectedUserProfilePhoto)

                        // A hack, but a functional hack
                        let existingPfp = customisations.profilePictureOverrideUrl
                        customisations.profilePictureOverrideUrl = url
                        if let existingPfp {
                            do {
                                try FileManager.default.removeItem(at: existingPfp)
                            } catch {
                                print(error)
                            }
                        }

                        self.selectedUserProfilePhoto = nil
                    } catch {
                        print(error)
                    }
                }

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
                        cancelEditing()
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

                tempCustomisations.profilePictureOverrideUrl = originalCustomisations.profilePictureOverrideUrl
                tempCustomisations.displayNameOverride = originalCustomisations.displayNameOverride
                tempCustomisations.background = originalCustomisations.background
                tempCustomisations.fontDesign = originalCustomisations.fontDesign
                tempCustomisations.textColor = originalCustomisations.textColor
                tempCustomisations.textEffects = originalCustomisations.textEffects

                customisations = tempCustomisations

                customName = tempCustomisations.displayNameOverride ?? ""
            }
        }
        .onChange(of: router.currentRoute) {
            cancelEditing()
        }
    }

    private func cancelEditing() {
        dismiss()
        customisations = originalCustomisations
    }

    private func saveChangesToOriginalCustomisations() {
        originalCustomisations.profilePictureOverrideUrl = customisations.profilePictureOverrideUrl
        originalCustomisations.displayNameOverride = customisations.displayNameOverride
        originalCustomisations.background = customisations.background
        originalCustomisations.fontDesign = customisations.fontDesign
        originalCustomisations.textColor = customisations.textColor
        originalCustomisations.textEffects = customisations.textEffects
    }
}
