//
//  BbMLContentViewer.swift
//  My Brighton
//
//  Created by Neo Salmon on 10/08/2025.
//

@preconcurrency import Translation
import SwiftBbML
import SwiftUI
import Router
import LearnKit

struct BbMLContentViewer: View {
    @Environment(Router.self) private var router
    @Environment(\.learnKitService) private var learnKit
    @Environment(\.locale) private var currentLocale
    @Environment(\.courseId) private var courseId

    @Binding private var content: Content

    @State private var bbML: BbMLContent = BbMLContent(header: nil, chunks: [])
    @State private var displayBbML: BbMLContent = BbMLContent(header: nil, chunks: [])

    @State private var isLoading: Bool = true

    @State private var showTranslationErrorAlert: Bool = false
    @State private var lastTranslationError: String? = nil
    @State private var availableTranslationLanguages: [Locale.Language]? = nil
    @State private var targetLanguage: Locale.Language = .contentLanguage

    @State private var showLoadFailedMessage: Bool = false
    @State private var loadFailedMessage: String = ""

    public init(content: Binding<Content>) {
        self._content = content
    }

    var body: some View {
        ScrollView {
            if targetLanguage != .contentLanguage {
                Label("Automatic translations may be inaccurate.", systemImage: "translate")
                    .font(.callout)
                    .foregroundStyle(.brightonSecondary)
                    .scenePadding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            BbMLView(displayBbML)
                .scenePadding(.horizontal)
        }
        .alert("Translation Error", isPresented: $showTranslationErrorAlert) {
            // TODO: Add button that clears error message and resets translation
        } message: {
            Text(lastTranslationError ?? "")
        }
        .alert("Unable to load content", isPresented: $showLoadFailedMessage) {
            Button("Retry") {
                showLoadFailedMessage = false
                loadFailedMessage = ""

                Task {
                    try await learnKit.refreshContent(for: content.id, includeChildren: true, in: courseId!)
                    await loadView(target: content)
                }
            }

            Button("Cancel") {
                showLoadFailedMessage = false
                loadFailedMessage = ""

                router.path.removeLast()
            }
        } message: {
            Text(loadFailedMessage)
        }
        .myBrightonBackground()
        .navigationTitle(content.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .userActivity(UserActivity.MyStudies.Content.view) {
            $0.title = "\(content.title) in {Module name}"
            // Spotlight
            $0.isEligibleForSearch = true
            // App Intents
            //$0.appEntityIdentifier = .init(for: T##Entity, identifier: T##Entity.ID)
        }
        .toolbarTitleMenu {
            Menu {
                Section("Available Formats") {
                    Button {

                    } label: {
                        Text("HTML")
                        Text("For viewing in the browser and on mobile devices")
                    }
                    Button {

                    } label: {
                        Text("ePub")
                        Text("For reading as an e-book on an iPad and other e-book readers")
                    }
                    Button {

                    } label: {
                        Text("Electronic Braille")
                    }
                    Button {

                    } label: {
                        Text("Audio")
                    }
                    Button {

                    } label: {
                        Text("BeeLine Reader")
                    }
                    Button {

                    } label: {
                        Text("Immersive Reader")

                    }
                    Button {

                    } label: {
                        Text("Translated Version")
                    }
                }
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .toolbar {
            ToolbarItem(id: "translation", placement: .secondaryAction) {
                Picker(selection: $targetLanguage) {
                    if let availableTranslationLanguages {
                            if availableTranslationLanguages.isEmpty {
                                Text("Translation is not available on this device.")
                                    .disabled(true)
                            } else {
                                Text("Original")
                                    .tag(Locale.Language.contentLanguage)

                                Section("Available Languages") {
                                    ForEach(availableTranslationLanguages, id: \.maximalIdentifier) { language in
                                        Text("\(getName(for: language)) (\(language.minimalIdentifier))")
                                            .tag(language)
                                    }
                                }
                            }
                    } else {
                        ProgressView("Please wait...")
                    }
                } label: {
                    Label("Translate", systemImage: "translate")
                }
            }
        }
        .task {
            await loadView(target: content)
        }
        .task {
            let availability = LanguageAvailability()
            let allLanguages = await availability.supportedLanguages

            self.availableTranslationLanguages = []

            for language in allLanguages {
                if await availability.status(from: .contentLanguage, to: language) != .unsupported {
                    self.availableTranslationLanguages!.append(language)
                }
            }
        }
        .translationTask(source: .contentLanguage, target: targetLanguage) { session in
            await translateContent(using: session)
        }
    }

    private func loadView(target: Content) async {
        do {
            switch target.handler {
                case .contentItem:
                    guard let contentBody = target.body else {
                        loadFailedMessage = "The content is empty."
                        showLoadFailedMessage = true

                        return
                    }

                    bbML = try BbMLParser.default.parse(contentBody)
                    displayBbML = bbML

                    isLoading = false

                    break
                case .contentFolder(isBbPage: let isBbPage):
                    guard isBbPage else {
                        loadFailedMessage = "The content is not a BbML document."
                        showLoadFailedMessage = true

                        return
                    }

                    if let childContent = try await learnKit.getChildContent(for: target.id, in: courseId!).first {
                        await loadView(target: childContent)
                    } else {
                        let updatedContent = try await learnKit.refreshContent(for: target.id, in: courseId!)
                        if updatedContent.isEmpty {
                            loadFailedMessage = "The content is empty."
                            showLoadFailedMessage = true
                            return
                        } else {
                            await loadView(target: content)
                        }
                    }

                    break
                default:
                    break
            }
        } catch {

        }
    }

    private func getName(for language: Locale.Language) -> String {
        let languageCode = language.languageCode?.identifier ?? ""
        let localizedDescription = currentLocale
            .localizedString(forLanguageCode: languageCode)

        return localizedDescription ?? "No description"
    }

    private func translateContent(using session: TranslationSession) async {
        if targetLanguage == .contentLanguage {
            displayBbML = bbML
            return
        }

        do {
            try await session.prepareTranslation()
        } catch {
            if let error = error as? TranslationError {
                lastTranslationError = error.failureReason
            }

            showTranslationErrorAlert = true
            return
        }

        displayBbML = bbML

        let requests: [TranslationSession.Request] = displayBbML.chunks.filter({
            if case .text(_) = $0 {
                return true
            } else {
                return false
            }
        }).map { textChunk in
            guard case let .text(attributedString) = textChunk else {
                fatalError()
            }

            // Map each item into a request.
            return TranslationSession.Request(sourceText: String(attributedString.characters))
        }

        Task { @MainActor in
            let responses = try await session.translations(from: requests)

            let replacementIndicies = displayBbML.chunks.filter({
                if case .text(_) = $0 {
                    return true
                } else {
                    return false
                }
            })
                .map { textChunk in
                    guard let index = displayBbML.chunks.firstIndex(of: textChunk) else { return -1 }

                    return index
                }

            var newChunks: [BbMLContent.Chunk] = []

            for index in 0..<displayBbML.chunks.count {
                if replacementIndicies.contains(index) {
                    guard case let .text(string) = displayBbML.chunks[index] else { return }

                    if let translatedText = responses.first(where: { $0.sourceText == String(string.characters) }) {
                        newChunks.append(.text(
                            AttributedString(
                                translatedText.targetText,
                            )
                        ))
                    }
                } else {
                    newChunks.append(displayBbML.chunks[index])
                }
            }

            displayBbML = BbMLContent(header: displayBbML.header, chunks: newChunks)
        }
    }
}

extension Locale.Language {
    static var contentLanguage: Locale.Language {
        .init(identifier: "en-GB")
    }
}

#Preview(traits: .environmentObjects, .learnKit) {
    NavigationStack {
        ContentWrapperView(for: "0_0")
            .environment(\.courseId, "_0_1")
    }
}
