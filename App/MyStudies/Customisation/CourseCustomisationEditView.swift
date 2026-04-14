//
//  CourseCustomisationEditView.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/04/2026.
//

import SwiftUI
import LearnKit
import CustomisationKit

struct CourseCustomisationEditView: View {
    @Environment(\.dismiss) private var dismiss

    let courseId: Course.ID
    let userCourseId: String
    let realName: String

    @State private var realCustomisations: CourseCustomisation = CourseCustomisation()
    @State private var tempCustomisations: CourseCustomisation = CourseCustomisation()

    @State private var customName: String = ""

    @State private var textColor: Color = .white

    private var previewDisplayName: String {
        customName.trimmingCharacters(in: .whitespaces).isEmpty ? realName : customName
    }

    init(for courseId: Course.ID, userCourseId: String, realName: String) {
        self.courseId = courseId
        self.userCourseId = userCourseId
        self.realName = realName
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preview") {
                    MyStudiesCourseCard(courseId: userCourseId, name: previewDisplayName, customisations: tempCustomisations)
                }

                Section {
                    TextField("Custom Name", text: $customName)
                } header: {
                    Text("Custom Name")
                } footer: {
                    Text("It is your responsibility to use a memorable and appropriate name for your module.\nThe module ID will always be displayed.")
                }
                .onChange(of: customName) {
                    if customName.trimmingCharacters(in: .whitespaces).isEmpty {
                        tempCustomisations.displayNameOverride = nil
                    } else {
                        tempCustomisations.displayNameOverride = customName
                    }
                }

                CustomisationBackgroundEditor(background: $tempCustomisations.background, courseId: courseId)

                CustomisationTextEffectsEditor(textColor: $textColor, fontDesign: $tempCustomisations.fontDesign, textAlignment: $tempCustomisations.textAlignment, textEffects: $tempCustomisations.textEffects)
                    .onChange(of: textColor) {
                        tempCustomisations.textColor = .fromColor(textColor)
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

                        CustomisationService.shared.discordOutstandingChanges()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .labelStyle(.designSystemAware)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()

                        storeChangesToRealCustomisations()
                        Task {
                            await CustomisationService.shared.updateThumbnail(for: courseId, fallbackName: realName)
                            MyBrightonAppShortcuts.updateAppShortcutParameters()
                        }
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .labelStyle(.designSystemAware)
                }
            }
            .onAppear {
                self.realCustomisations = CustomisationService.shared.getCourseCustomisation(for: courseId)

                tempCustomisations.displayNameOverride = realCustomisations.displayNameOverride
                tempCustomisations.background = realCustomisations.background

                tempCustomisations.textColor = realCustomisations.textColor
                tempCustomisations.fontDesign = realCustomisations.fontDesign
                tempCustomisations.textAlignment = realCustomisations.textAlignment

                tempCustomisations.textEffects = realCustomisations.textEffects

                customName = tempCustomisations.displayNameOverride ?? ""
                textColor = tempCustomisations.textColor.resolved
            }
        }
    }

    private func storeChangesToRealCustomisations() {
        realCustomisations.displayNameOverride = tempCustomisations.displayNameOverride

        realCustomisations.background = tempCustomisations.background

        realCustomisations.textColor = tempCustomisations.textColor
        realCustomisations.fontDesign = tempCustomisations.fontDesign
        realCustomisations.textAlignment = tempCustomisations.textAlignment

        realCustomisations.textEffects = tempCustomisations.textEffects

        CustomisationService.shared.saveOutstandingChanges()
    }
}

#Preview(traits: .learnKit, .customisationKit) {
    CourseCustomisationEditView(for: "_0_1", userCourseId: "MB_DEBUG", realName: "Debugging Course")
}
