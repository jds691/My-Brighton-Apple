//
//  CustomisedBackgroundImagePickerView.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/04/2026.
//

import Foundation
import SwiftUI
import CustomisationKit

struct CustomisedBackgroundImagePickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var colours: [Color] = []
    @State private var collections: [ImageCollection] = []

    @Binding var background: BackgroundType

    @State private var customColor: Color = .primary

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                Section {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(colours, id: \.self) { colour in
                                colour
                                    .frame(
                                        minWidth: 0,
                                        maxWidth: .infinity,
                                        minHeight: 0,
                                        maxHeight: .infinity
                                    )
                                    .aspectRatio(aspectRatio, contentMode: .fit)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .contentShape(RoundedRectangle(cornerRadius: 16))
                                    .containerRelativeFrame([.horizontal], count: 3, span: 1, spacing: 8)
                                    .onTapGesture {
                                        background = .color(.fromColor(colour))
                                        dismiss()
                                    }
                            }
                        }
                        .fixedSize()
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                } header: {
                    Text("Colours")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }

                ForEach(collections, id: \.name) { collection in
                    Section {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(collection.paths, id: \.self) { path in
                                    Image(path, bundle: Bundle(for: CustomisationService.self))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            minWidth: 0,
                                            maxWidth: .infinity,
                                            minHeight: 0,
                                            maxHeight: .infinity
                                        )
                                        .aspectRatio(aspectRatio, contentMode: .fit)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .contentShape(RoundedRectangle(cornerRadius: 16))
                                        .containerRelativeFrame([.horizontal], count: 3, span: 1, spacing: 8)
                                        .onTapGesture {
                                            background = .builtInImage(path)
                                            dismiss()
                                        }
                                }
                            }
                            .fixedSize()
                            .scrollTargetLayout()
                        }
                        .contentMargins(.horizontal, 16, for: .scrollContent)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                    } header: {
                        Text(collection.name)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Select a background")
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
                }
            }
        }
        .onAppear {
            do {
                colours = CustomisationService.getBuiltInColours()
                collections = try CustomisationService.getBuiltInImageCollections()
            } catch {
                // TODO: Replace with alert explaining error
                dismiss()
            }
        }
    }

    private var aspectRatio: CGFloat {
        361 / 185
    }
}

#Preview {
    CustomisedBackgroundImagePickerView(background: .constant(.color(.fromColor(.accentColor))))
}
