//
//  OnboardingSignInView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI
import PhotosUI
import CoreDesign
import Accounts
import CustomisationKit
import LearnKit

struct OnboardingCustomiseView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @Environment(\.accountService) private var accountService
    @Environment(\.learnKitService) private var learnKit

    @Binding var displayContentView: Bool

    @State private var overrideName: String = ""
    @State private var showProfilePicturePicker: Bool = false
    @State private var selectedUserProfilePhoto: PhotosPickerItem? = nil

#if canImport(UIKit)
    @State private var showProfilePictureCamera: Bool = false
    @State private var takenProfilePicture: UIImage?
#endif

    @State private var homeCustomisations: HomeCustomisation = HomeCustomisation()

    @State private var initialising: Bool = false

    @State private var currentDownloadTask: String = "Downloading content..."

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: homeCustomisations.profilePictureOverrideUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.brightonSecondary
            }
            .accessibilityHidden(true)
            .frame(width: 128.0, height: 128.0)
            .clipShape(Circle())
            .padding(3)
            .overlay {
                Circle()
                    .strokeBorder(lineWidth: 3, antialiased: true)
                    .foregroundStyle(.primary)
            }

            HStack {
                Button {
                    showProfilePicturePicker = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .modifier(CustomisedBackgroundImagePickerCard())
                }
                .frame(minWidth: 115, minHeight: 66)

#if canImport(UIKit)
                Button {
                    showProfilePictureCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .modifier(CustomisedBackgroundImagePickerCard())
                }
                .frame(minWidth: 115, minHeight: 66)
#endif
            }
            .buttonStyle(.plain)

            VStack(spacing: 0) {
                Text(timeOfDayString() + ",")
                    .bold()
                TextField("Name", text: $overrideName)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.underlined)
                #if os(iOS)
                    .textInputAutocapitalization(.words)
                #endif
            }
            .font(.largeTitle)

#if os(macOS)
            if #available(macOS 26, *) {
                interactionView
            } else {
                interactionView
            }
#endif
        }
        .onAppear {
            homeCustomisations = CustomisationService.shared.getHomeCustomisation()
            overrideName = (try? accountService.getAccountDetails().fullName) ?? ""
        }
        .photosPicker(isPresented: $showProfilePicturePicker, selection: $selectedUserProfilePhoto, matching: .images)
        .task(id: selectedUserProfilePhoto) {
            guard let selectedUserProfilePhoto else { return }

            do {
                let url = try await CustomisationService.storePhotosPickerProfilePictureItem(selectedUserProfilePhoto)

                let existingPfp = homeCustomisations.profilePictureOverrideUrl
                homeCustomisations.profilePictureOverrideUrl = url
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
        .navigationTitle("Sign In")
#if os(iOS)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .navigationBarTitleDisplayMode(.inline)
        .modifierBranch {
            if #available(iOS 26, macOS 26, *) {
                $0
                    .safeAreaBar(edge: .bottom) {
                        interactionView
                    }
            } else {
                $0
                    .safeAreaInset(edge: .bottom) {
                        interactionView
                    }
            }
        }
#endif
#if canImport(UIKit)
        .cameraCapture(isPresented: $showProfilePictureCamera, image: $takenProfilePicture, preferredCamera: .front)
        .onChange(of: takenProfilePicture) {
            guard let takenProfilePicture else { return }

            Task {
                do {
                    let url = try await CustomisationService.storeProfilePicture(takenProfilePicture)

                    // A hack, but a functional hack
                    let existingPfp = homeCustomisations.profilePictureOverrideUrl
                    homeCustomisations.profilePictureOverrideUrl = url
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
        }
#endif
        .scenePadding()
    }

    @ViewBuilder
    private var interactionView: some View {
        if initialising {
            ProgressView {
                Text(currentDownloadTask)
            }
        } else {
            if #available(iOS 26, macOS 26, *) {
                Button {
                    Task {
                        await initialiseSystem()
                    }
                } label: {
                    Text("Continue")
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.glassProminent)
                .keyboardShortcut(.defaultAction)
            } else {
                Button {
                    Task {
                        await initialiseSystem()
                    }
                } label: {
                    Text("Continue")
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
    }

    private func initialiseSystem() async {
        initialising = true

        defer {
            #if os(macOS)
            NSApplication.shared.requestUserAttention(.informationalRequest)
            openWindow(id: "main")
            dismissWindow(id: "sign-in")
            #else
            displayContentView = true
            #endif
        }

        if overrideName.trimmingCharacters(in: .whitespaces).isEmpty {
            homeCustomisations.displayNameOverride = nil
        } else if let accountName = try? accountService.getAccountDetails().fullName, accountName == overrideName {
            homeCustomisations.displayNameOverride = nil
        } else {
            homeCustomisations.displayNameOverride = overrideName
        }

        CustomisationService.shared.saveOutstandingChanges()

        do {
            currentDownloadTask = "Downloading terms"
            try await learnKit.refreshTerms()
            currentDownloadTask = "Downloading courses"
            let courses = try await learnKit.refreshCourses()
            currentDownloadTask = "Downloading course contents"
            try await withThrowingTaskGroup { group in
                for course in courses {
                    await CustomisationService.shared.updateThumbnail(for: course.id, fallbackName: course.name)
                    group.addTask { try await learnKit.refreshContent(for: "ROOT", includeChildren: true, in: course.id) }
                }

                try await group.waitForAll()
            }
            currentDownloadTask = "Downloading course announcements"
            try await withThrowingTaskGroup { group in
                for course in courses {
                    group.addTask { try await learnKit.refreshCourseAnnouncements(for: course.id) }
                }

                try await group.waitForAll()
            }
            currentDownloadTask = "Downloading assignments"
            try await withThrowingTaskGroup { group in
                for course in courses {
                    group.addTask { (columns: try await learnKit.refreshGradeColumns(for: course.id), courseId: course.id) }
                }

                for try await result in group {
                    try await withThrowingTaskGroup { attemptsGroup in
                        for column in result.columns {
                            attemptsGroup.addTask { try await learnKit.refreshGradebookAttempts(for: column.id, in: result.courseId) }
                        }

                        try await attemptsGroup.waitForAll()
                    }
                }
            }
        } catch {
            print(error)
        }
    }

    private func timeOfDayString() -> String {
        let hour = Calendar.current.component(.hour, from: .now)

        if hour < 12 {
            return String(
                localized: "home.header.tod.morning",
                defaultValue: "Good Morning",
                table: "Home"
            )
        } else if hour >= 12 && hour < 17 {
            return String(
                localized: "home.header.tod.afternoon",
                defaultValue: "Good Afternoon",
                table: "Home"
            )
        } else {
            return String(
                localized: "home.header.tod.evening",
                defaultValue: "Good Evening",
                table: "Home"
            )
        }
    }
}
