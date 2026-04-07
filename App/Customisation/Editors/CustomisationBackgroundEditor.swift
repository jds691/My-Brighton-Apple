//
//  CustomisationBackgroundEditor.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import SwiftUI
import LearnKit
import CustomisationKit

struct CustomisationBackgroundEditor: View {
    let courseId: Course.ID?

    @Binding var background: CustomisationKit.BackgroundType

    @State private var backgroundType: BackgroundType = .color

    @State private var backgroundColor: Color = .brightonSecondary
    @State private var backgroundImageBuiltInIdentifier: String = CustomisationService.getAlwaysPresentImagePath()

    @State private var showBackgroundPicker: Bool = false

    @State private var disableTwoWayOnChange: Bool = false

    init(background: Binding<CustomisationKit.BackgroundType>) {
        self._background = background
        self.courseId = nil
    }

    init(background: Binding<CustomisationKit.BackgroundType>, courseId: Course.ID) {
        self._background = background
        self.courseId = courseId
    }

    var body: some View {
        Group {
            Section("Background") {
                Picker("Style", selection: $backgroundType) {
                    Text("Colour")
                        .tag(Self.BackgroundType.color)
                    Text("Image")
                        .tag(Self.BackgroundType.image)
                }

                switch backgroundType {
                    case .color:
                        ColorPicker("Colour", selection: $backgroundColor)
                    case .image:
                        HStack {
                            Text("Image")
                            Spacer()
                            Button("Choose") {
                                showBackgroundPicker = true
                            }
                        }
                        .sheet(isPresented: $showBackgroundPicker) {
                            if let courseId {
                                CustomisedBackgroundImagePickerView(background: $background, courseId: courseId)
                            } else {
                                CustomisedBackgroundImagePickerView(background: $background)
                            }
                        }
                }
            }
            .onChange(of: background) {
                if disableTwoWayOnChange {
                    disableTwoWayOnChange = false
                    return
                }

                switch background {
                    case .color(let color):
                        backgroundColor = color.resolved

                        if case .color = backgroundType {
                            break
                        }

                        disableTwoWayOnChange = true
                        backgroundType = .color
                    case .builtInImage(let path):
                        backgroundImageBuiltInIdentifier = path

                        if case .image = backgroundType {
                            break
                        }

                        disableTwoWayOnChange = true
                        backgroundType = .image
                    case .customImage(_):
                        if case .image = backgroundType {
                            break
                        }

                        disableTwoWayOnChange = true
                        backgroundType = .image
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
                        background = .color(.fromColor(backgroundColor))
                    case .image:
                        background = .builtInImage(backgroundImageBuiltInIdentifier)
                }
            }
            .onChange(of: backgroundColor) {
                if disableTwoWayOnChange {
                    disableTwoWayOnChange = false
                    return
                }

                disableTwoWayOnChange = true
                background = .color(.fromColor(backgroundColor))
            }
        }
        .onAppear {
            disableTwoWayOnChange = true
            switch background {
                case .color(let codableColor):
                    backgroundColor = codableColor.resolved
                    backgroundType = .color
                case .builtInImage(let path):
                    backgroundImageBuiltInIdentifier = path
                    backgroundType = .image
                case .customImage(_):
                    backgroundType = .image
            }
        }
    }

    private enum BackgroundType: Hashable {
        case color
        case image
    }
}
