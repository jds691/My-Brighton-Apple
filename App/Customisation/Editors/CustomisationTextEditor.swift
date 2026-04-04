//
//  CustomisationTextEffectsEditor.swift
//  My Brighton
//
//  Created by Neo Salmon on 04/04/2026.
//

import SwiftUI
import CustomisationKit

struct CustomisationTextEffectsEditor: View {
    @Binding var textColor: Color
    @Binding var fontDesign: FontDesign
    @Binding var textAlignment: CustomisationKit.TextAlignment
    @Binding var textEffects: TextEffects

    // Text Effect flags
    @State private var dropShadow: Bool = false
    @State private var boldText: Bool = false
    @State private var italicText: Bool = false
    @State private var underlineText: Bool = false
    @State private var strikethroughText: Bool = false

    var body: some View {
        Group {
            Section("Text") {
                ColorPicker("Colour", selection: $textColor)
                Picker("Style", selection: $fontDesign) {
                    Text("Default")
                        .tag(FontDesign.regular)
                    Text("Rounded")
                        .tag(FontDesign.rounded)
                    Text("Serif")
                        .tag(FontDesign.serif)
                    Text("Monospaced")
                        .tag(FontDesign.monospace)
                }
                Picker("Alignment", selection: $textAlignment) {
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
            /*.onChange(of: textColor) {
             tempCustomisations.textColor = .fromColor(textColor)
             }*/

            Section("Text Effects") {
                Toggle("Drop Shadow", systemImage: "shadow", isOn: $dropShadow)
                Toggle("Bold", systemImage: "bold", isOn: $boldText)
                Toggle("Italic", systemImage: "italic", isOn: $italicText)
                Toggle("Underline", systemImage: "underline", isOn: $underlineText)
                Toggle("Strikethrough", systemImage: "strikethrough", isOn: $strikethroughText)
            }
            .onChange(of: dropShadow) {
                if dropShadow {
                    textEffects.insert(.dropShadow)
                } else {
                    textEffects.remove(.dropShadow)
                }
            }
            .onChange(of: boldText) {
                if boldText {
                    textEffects.insert(.bold)
                } else {
                    textEffects.remove(.bold)
                }
            }
            .onChange(of: italicText) {
                if italicText {
                    textEffects.insert(.italics)
                } else {
                    textEffects.remove(.italics)
                }
            }
            .onChange(of: underlineText) {
                if underlineText {
                    textEffects.insert(.underline)
                } else {
                    textEffects.remove(.underline)
                }
            }
            .onChange(of: strikethroughText) {
                if strikethroughText {
                    textEffects.insert(.strikethrough)
                } else {
                    textEffects.remove(.strikethrough)
                }
            }
        }
        .onAppear {
            setTextEffectBools()
        }
        .onChange(of: textEffects) {
            setTextEffectBools()
        }
    }

    private func setTextEffectBools() {
        dropShadow = textEffects.contains(.dropShadow)
        boldText = textEffects.contains(.bold)
        italicText = textEffects.contains(.italics)
        underlineText = textEffects.contains(.underline)
        strikethroughText = textEffects.contains(.strikethrough)
    }
}
