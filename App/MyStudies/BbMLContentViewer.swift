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

struct BbMLContentViewer: View {
    @Environment(\.locale) private var currentLocale

    private let title: LocalizedStringResource
    private let bbML: BbMLContent

    @State private var displayBbML: BbMLContent

    @State private var showTranslationErrorAlert: Bool = false
    @State private var lastTranslationError: String? = nil
    @State private var availableTranslationLanguages: [Locale.Language]? = nil
    //@AppStorage("MyStudies.Translation.targetLanguage")
    @State private var targetLanguage: Locale.Language = .contentLanguage

    public init(_ bbML: BbMLContent, title: LocalizedStringResource) {
        self.bbML = bbML
        self.title = title

        self._displayBbML = State(initialValue: self.bbML)
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
        .myBrightonBackground()
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .userActivity(UserActivity.MyStudies.Content.view) {
            $0.title = "\(title) in {Module name}"
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

            /*#if os(iOS)
            let textAttributes: AttributeContainer = AttributeContainer([
                .accessibilitySpeechLanguage : "fr" ?? "en"
            ])
            #else
            let textAttributes: AttributeContainer = AttributeContainer([:])
            #endif*/

            for index in 0..<displayBbML.chunks.count {
                if replacementIndicies.contains(index) {
                    guard case let .text(string) = displayBbML.chunks[index] else { return }

                    if let translatedText = responses.first(where: { $0.sourceText == String(string.characters) }) {
                        newChunks.append(.text(
                            AttributedString(
                                translatedText.targetText,
                                /*attributes: textAttributes*/
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

#Preview {
    NavigationStack {
        BbMLContentViewer(
            BbMLContent(
                header: .init(),
                chunks: [
                    .text("Hello?"),
                    .text("I'm attempting to render some maths now:"),
                    .math(mathML:
                    """
                    <mrow>
                    <mi>x</mi>
                    <mo>=</mo>
                    <mfrac>
                    <mrow>
                    <mrow>
                    <mo>−</mo>
                    <mi>b</mi>
                    </mrow>
                    <mo>±</mo>
                    <msqrt>
                    <mrow>
                    <msup>
                    <mi>b</mi>
                    <mn>2</mn>
                    </msup>
                    <mo>−</mo>
                    <mrow>
                    <mn>4</mn>
                    <mo>⁢</mo>
                    <mi>a</mi>
                    <mo>⁢</mo>
                    <mi>c</mi>
                    </mrow>
                    </mrow>
                    </msqrt>
                    </mrow>
                    <mrow>
                    <mn>2</mn>
                    <mo>⁢</mo>
                    <mi>a</mi>
                    </mrow>
                    </mfrac>
                    </mrow>
                    """),
                    .text("Here is now Peter Griffen from hit show Family Guy:"),
                    .image(url: URL(string: "https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png")!, altDescription: "Peter Griffen", decorative: false)
                ]
            ), title: "Preview"
        )
    }
}
