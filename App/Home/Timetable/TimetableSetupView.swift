//
//  TimetableSetupView.swift
//  My Brighton
//
//  Created by Neo Salmon on 14/09/2025.
//

import SwiftUI
import Timetable

struct TimetableSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.timetableService) private var timetableService

    @AppStorage(TimetableService.remoteURLUserDefaultsKey) private var timetableURL: URL?
    @State private var timetableURLText: String = ""
    @State private var showInvalidUrlAlert: Bool = false

    @State private var setupStep: SetupStep = .urlEntry

    var body: some View {
        NavigationStack {
            Group {
                switch setupStep {
                    case .urlEntry:
                        urlEntryStepView
                            //.transition(.slide)
                    case .verified:
                        verifiedStepView
                            //.transition(.slide)
                }
            }
            .navigationTitle("Timetable Setup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(macOS)
            .scenePadding()
            #endif
        }
        .onAppear {
            if let timetableURL {
                timetableURLText = timetableURL.path(percentEncoded: false)
            }
        }
    }

    @ViewBuilder
    private var urlEntryStepView: some View {
        Form {
            Section {
                TextField(text: $timetableURLText, prompt: Text("URL")) {
                    Text("Timetable URL")
                }
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                #endif
            } header: {
                
            } footer: {
                Text(
                        """
You'll need to provide a link to your timetable from the timetable in the web My Brighton.

You can find it in [My Brighton > Timetable > Administration > My mobile](https://timetablego.brighton.ac.uk/CMISGo/Web/Timetable)
"""
                )
            }
        }
        .alert("Invalid URL", isPresented: $showInvalidUrlAlert) {

        } message: {
            Text("The URL you specified is not a valid link to a timetable. Please follow the instructions listed to continue.")
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    // TODO: Add actual URL validation, this doesn't really work
                    // Also make sure it points to an actual ICS file
                    if let validUrl = URL(string: timetableURLText) {
                        timetableURL = validUrl
                        print(validUrl)
                        timetableService.setRemoteURL(validUrl)
                        setupStep = .verified
                    } else {
                        showInvalidUrlAlert = true
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var verifiedStepView: some View {
        Form {
            VStack {
                Image(systemName: "checkmark.circle")
                    .symbolRenderingMode(.multicolor)
                Text("Setup Complete")
                    .font(.largeTitle.bold())
                Text("Your timetable is ready to use. You can configure some additional settings below:")
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
                .labelStyle(.designSystemAware)
            }
        }
    }

    private enum SetupStep {
        case urlEntry
        case verified
    }
}

#Preview(traits: .timetableService) {
    TimetableSetupView()
}
