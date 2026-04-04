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
    @State private var dropShadow: Bool = false
    @State private var boldText: Bool = false
    @State private var italicText: Bool = false
    @State private var underlineText: Bool = false
    @State private var strikethroughText: Bool = false

    @State private var backgroundType: BackgroundType = .color

    @State private var backgroundColor: Color = .brightonSecondary
    @State private var backgroundImageBuiltInIdentifier: String = CustomisationService.getAlwaysPresentImagePath()

    @State private var showBackgroundPicker: Bool = false

    @State private var disableTwoWayOnChange: Bool = false

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

                Section("Background") {
                    Picker("Style", selection: $backgroundType) {
                        Text("Colour")
                            .tag(BackgroundType.color)
                        Text("Image")
                            .tag(BackgroundType.builtInImage)
                    }

                    switch backgroundType {
                        case .color:
                            ColorPicker("Colour", selection: $backgroundColor)
                        case .builtInImage:
                            HStack {
                                Text("Image")
                                Spacer()
                                Button("Choose") {
                                    showBackgroundPicker = true
                                }
                            }
                    }
                }
                .onChange(of: tempCustomisations.background) {
                    if disableTwoWayOnChange {
                        disableTwoWayOnChange = false
                        return
                    }

                    switch tempCustomisations.background {
                        case .color(let color):
                            backgroundColor = color.resolved

                            if case .color = backgroundType {
                                break
                            }

                            disableTwoWayOnChange = true
                            backgroundType = .color
                        case .builtInImage(let path):
                            backgroundImageBuiltInIdentifier = path

                            if case .builtInImage = backgroundType {
                                break
                            }

                            disableTwoWayOnChange = true
                            backgroundType = .builtInImage
                            if !dropShadow {
                                dropShadow = true
                            }
                        @unknown default:
                            break
                    }
                }
                .onChange(of: backgroundType) {
                    if disableTwoWayOnChange {
                        disableTwoWayOnChange = false
                        return
                    }

                    disableTwoWayOnChange = true
                    switch backgroundType {
                        case .color:
                            tempCustomisations.background = .color(.fromColor(backgroundColor))
                        case .builtInImage:
                            tempCustomisations.background = .builtInImage(backgroundImageBuiltInIdentifier)
                            if !dropShadow {
                                dropShadow = true
                            }
                    }
                }
                .onChange(of: backgroundColor) {
                    if disableTwoWayOnChange {
                        disableTwoWayOnChange = false
                        return
                    }

                    disableTwoWayOnChange = true
                    tempCustomisations.background = .color(.fromColor(backgroundColor))
                }

                Section("Text") {
                    ColorPicker("Colour", selection: $textColor)
                    Picker("Style", selection: $tempCustomisations.fontDesign) {
                        Text("Default")
                            .tag(FontDesign.regular)
                        Text("Rounded")
                            .tag(FontDesign.rounded)
                        Text("Serif")
                            .tag(FontDesign.serif)
                        Text("Monospaced")
                            .tag(FontDesign.monospace)
                    }
                    Picker("Alignment", selection: $tempCustomisations.textAlignment) {
                        Text("Top Left")
                            .tag(CustomisationKit.TextAlignment.topLeading)
                        Text("Top Center")
                            .tag(CustomisationKit.TextAlignment.top)
                        Text("Top Right")
                            .tag(CustomisationKit.TextAlignment.topTrailing)

                        Divider()

                        Text("Center Left")
                            .tag(CustomisationKit.TextAlignment.centerLeading)
                        Text("Center")
                            .tag(CustomisationKit.TextAlignment.center)
                        Text("Center Right")
                            .tag(CustomisationKit.TextAlignment.centerTrailing)

                        Divider()

                        Text("Bottom Left")
                            .tag(CustomisationKit.TextAlignment.bottomLeading)
                        Text("Bottom Center")
                            .tag(CustomisationKit.TextAlignment.bottom)
                        Text("Bottom Right")
                            .tag(CustomisationKit.TextAlignment.bottomTrailing)
                    }
                }
                .onChange(of: textColor) {
                    tempCustomisations.textColor = .fromColor(textColor)
                }

                Section("Text Effects") {
                    Toggle("Drop Shadow", systemImage: "shadow", isOn: $dropShadow)
                    Toggle("Bold", systemImage: "bold", isOn: $boldText)
                    Toggle("Italic", systemImage: "italic", isOn: $italicText)
                    Toggle("Underline", systemImage: "underline", isOn: $underlineText)
                    Toggle("Strikethrough", systemImage: "strikethrough", isOn: $strikethroughText)
                }
                .onChange(of: dropShadow) {
                    if dropShadow {
                        tempCustomisations.textEffects.insert(.dropShadow)
                    } else {
                        tempCustomisations.textEffects.remove(.dropShadow)
                    }
                }
                .onChange(of: boldText) {
                    if boldText {
                        tempCustomisations.textEffects.insert(.bold)
                    } else {
                        tempCustomisations.textEffects.remove(.bold)
                    }
                }
                .onChange(of: italicText) {
                    if italicText {
                        tempCustomisations.textEffects.insert(.italics)
                    } else {
                        tempCustomisations.textEffects.remove(.italics)
                    }
                }
                .onChange(of: underlineText) {
                    if underlineText {
                        tempCustomisations.textEffects.insert(.underline)
                    } else {
                        tempCustomisations.textEffects.remove(.underline)
                    }
                }
                .onChange(of: strikethroughText) {
                    if strikethroughText {
                        tempCustomisations.textEffects.insert(.strikethrough)
                    } else {
                        tempCustomisations.textEffects.remove(.strikethrough)
                    }
                }
            }
            .sheet(isPresented: $showBackgroundPicker) {
                CustomisedBackgroundImagePickerView(background: $tempCustomisations.background)
            }
            .navigationTitle("Customise")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .labelStyle(.designSystemAware)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()

                        storeChangesToRealCustomisations()
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

                disableTwoWayOnChange = true
                switch tempCustomisations.background {
                    case .color(let codableColor):
                        backgroundColor = codableColor.resolved
                        backgroundType = .color
                    case .builtInImage(let path):
                        backgroundImageBuiltInIdentifier = path
                        backgroundType = .builtInImage
                    default:
                        break
                }

                dropShadow = tempCustomisations.textEffects.contains(.dropShadow)
                boldText = tempCustomisations.textEffects.contains(.bold)
                italicText = tempCustomisations.textEffects.contains(.italics)
                underlineText = tempCustomisations.textEffects.contains(.underline)
                strikethroughText = tempCustomisations.textEffects.contains(.strikethrough)
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
    }

    private enum BackgroundType: Hashable {
        case color
        case builtInImage
    }
}

#Preview(traits: .learnKit, .customisationKit) {
    CourseCustomisationEditView(for: "_0_1", userCourseId: "MB_DEBUG", realName: "Debugging Course")
}
