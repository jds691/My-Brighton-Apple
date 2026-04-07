//
//  CustomisedBackgroundImagePickerView.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/04/2026.
//

import Foundation
import PhotosUI
import SwiftUI
import LearnKit
import CustomisationKit
import CoreDesign

struct CustomisedBackgroundImagePickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var colours: [Color] = []
    @State private var collections: [ImageCollection] = []

    @State var userPhotoSelection: PhotosPickerItem? = nil

    #if canImport(UIKit)
    @State private var showCameraCapture: Bool = false
    @State private var capturedPhoto: UIImage? = nil
    #endif

    @Binding var background: BackgroundType

    @State private var customColor: Color = .primary

    private let courseId: Course.ID?

    init(background: Binding<CustomisationKit.BackgroundType>) {
        self._background = background
        self.courseId = nil
    }

    init(background: Binding<CustomisationKit.BackgroundType>, courseId: Course.ID) {
        self._background = background
        self.courseId = courseId
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                Section {
                    ScrollView(.horizontal) {
                        HStack {
                            PhotosPicker(selection: $userPhotoSelection, matching: .images) {
                                Image(systemName: "photo.on.rectangle")
                                    .imageScale(.large)
                                    .modifier(CustomisedBackgroundImagePickerCard())
                            }

                            #if canImport(UIKit)
                            Button {
                                showCameraCapture = true
                            } label: {
                                Image(systemName: "camera")
                                    .imageScale(.large)
                                    .modifier(CustomisedBackgroundImagePickerCard())
                            }
                            #endif
                        }
                        .fixedSize()
                        .scrollTargetLayout()
                        .buttonStyle(.plain)
                    }
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                } header: {
                    Text("Custom Image")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }

                Section {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(colours, id: \.self) { colour in
                                colour
                                    .modifier(CustomisedBackgroundImagePickerCard())
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
                                        .modifier(CustomisedBackgroundImagePickerCard())
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
                print(error)
                // TODO: Replace with alert explaining error
                dismiss()
            }
        }
        .task(id: userPhotoSelection) {
            guard let userPhotoSelection else { return }

            do {
                // Forces views to re-draw and fetch the new image if the previous image was also custom
                // A hack? Surely not...
                if case .customImage(let url) = background {
                    background = .color(.fromColor(.brightonSecondary))
                }
                if let courseId {
                    background = .customImage(try await CustomisationService.storePhotosPickerBackgroundItem(userPhotoSelection, for: courseId))
                } else {
                    background = .customImage(try await CustomisationService.storePhotosPickerBackgroundItem(userPhotoSelection))
                }

                dismiss()
            } catch {
                print(error)
                // TODO: Show error
            }
        }
        #if canImport(UIKit)
        .cameraCapture(isPresented: $showCameraCapture, image: $capturedPhoto)
        .onChange(of: capturedPhoto) {
            guard let capturedPhoto else { return }

            if case .customImage(_) = background {
                background = .color(.fromColor(.brightonSecondary))
            }

            Task {
                do {
                    if let courseId {
                        background = .customImage(try await CustomisationService.storeBackgroundImage(capturedPhoto, for: courseId))
                    } else {
                        background = .customImage(try await CustomisationService.storeBackgroundImage(capturedPhoto))
                    }

                    dismiss()
                } catch {
                    print(error)
                }

            }
        }
        #endif
    }
}

struct CustomisedBackgroundImagePickerCard: ViewModifier {
    func body(content: Self.Content) -> some View {
            content
                .aspectRatio(contentMode: .fill)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .aspectRatio(361 / 185, contentMode: .fit)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .circular))
                .contentShape(RoundedRectangle(cornerRadius: 24, style: .circular))
                .padding(6)
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .circular)
                        .strokeBorder(lineWidth: 3, antialiased: true)
                }
                .containerRelativeFrame([.horizontal], count: 3, span: 1, spacing: 8)
    }
}

#Preview {
    CustomisedBackgroundImagePickerView(background: .constant(.color(.fromColor(.accentColor))))
}
