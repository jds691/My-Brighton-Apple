//
//  GetTimetableIntent.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/08/2025.
//

import AppIntents
import SwiftUI
import Timetable
import Router

// TODO: The app shortcut always uses 11 AM UTC when pressed despite the value always being set to now
// I have no fucking clue what causes this

public struct GetTimetableIntent: AppIntent {
    public static let title: LocalizedStringResource = "Get Timetable"
    public static let description: IntentDescription? = IntentDescription("Gets your timetable for the given date", categoryName: "Timetable", resultValueName: "Classes")

    @available(iOS 26, macOS 26, *)
    public static let supportedModes: IntentModes = [.background, .foreground(.dynamic)]

    @Dependency
    private var router: Router
    @Dependency
    private var timetableService: TimetableService

    @Parameter(kind: .date, requestValueDialog: "What day would you like the timetable for?")
    public var date: Date

    public static var parameterSummary: some ParameterSummary {
        Summary("Get timetable for \(\.$date)")
    }

    public init() {
    }

    public init(date: Date) {
        self.date = date
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ShowsSnippetView & ProvidesDialog & ReturnsValue<[ScheduledClassEntity]> {
        guard timetableService.canFetchTimetable else {
            throw needsToContinueInForegroundError("You'll need to connect your timetable to My Brighton in-app to continue.") {
                router.navigate(to: .modal(.timetableSetup))
            }
        }

        let fetchDate: Date

        if date.withoutTime != .now.withoutTime {
            fetchDate = date.withoutTime
        } else {
            fetchDate = date
        }

        let classes = try await timetableService.getClasses(after: fetchDate).map { ScheduledClassEntity(from: $0) }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current

        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .long
        timeFormatter.locale = Locale.current

        // MARK: Localisation
        let noClassesDialogString: LocalizedStringResource = .init(
            "GetTimetableIntent.dialog.no-classes",
            defaultValue: "There are no classes scheduled for \(dateFormatter.string(from: date)).",
            //table: "Intents"
            bundle: #bundle
        )

        let noMoreClassesTodayFullDialogString: LocalizedStringResource = .init(
            "GetTimetableIntent.dialog.today.no-classes.full",
            defaultValue: "There were \(classes.count) classes today. There are no more classes to attend today.",
            //table: "Intents"
            bundle: #bundle
        )

        let classesPastDialogString: LocalizedStringResource = .init(
            "GetTimetableIntent.dialog.classes.past",
            defaultValue: "There were \(classes.count) classes on \(dateFormatter.string(from: date)).",
            //table: "Intents"
            bundle: #bundle
        )

        let classesFutureDialogString: LocalizedStringResource = .init(
            "GetTimetableIntent.dialog.classes.future",
            defaultValue: "There are \(classes.count) classes on \(dateFormatter.string(from: date)).",
            //table: "Intents"
            bundle: #bundle
        )

        // MARK: Perform
        if classes.isEmpty {
            return .result(
                value: [],
                dialog: .init(noClassesDialogString)
            )
        } else {
            // TODO: Check if this dialog is natural
            let resultDialog: IntentDialog

            if date.withoutTime == .now.withoutTime { // Date is Today
                if .now > classes.last!.endDate { // No more classes later
                    resultDialog = IntentDialog(full: noMoreClassesTodayFullDialogString, supporting: "There were \(classes.count) today.")
                } else { // More classes later
                    // Mmmmm, I love force unwrapping
                    // * The air crackles with confidence
                    let nextClass = classes.first(where: { $0.startDate > .now })!
                    let nextClassIndex = classes.firstIndex(where: { $0.startDate > .now })!
                    let remainingClasses = classes.count - (nextClassIndex + 1)
                    resultDialog = IntentDialog(full: "There are \(classes.count) classes today. The next class is \(nextClass.name) at \(timeFormatter.string(from: nextClass.startDate)) with \(remainingClasses) more classes later in the day.", supporting: "There are \(classes.count) classes today.")
                }
            } else if date.withoutTime < .now.withoutTime { // Date is in the past
                resultDialog = IntentDialog(classesPastDialogString)
            } else { // Date is in the future
                resultDialog = IntentDialog(classesFutureDialogString)
            }

            return .result(
                value: classes,
                dialog: resultDialog,
                view: GetTimetableIntentSnippetView(classes)
            )
        }
    }
}

extension GetTimetableIntent: PredictableIntent {
    public static var predictionConfiguration: some IntentPredictionConfiguration {
        let namedRelativeFormatter: Date.RelativeFormatStyle = {
            var formatter = Date.RelativeFormatStyle()
            formatter.presentation = .named
            formatter.unitsStyle = .spellOut
            formatter.capitalizationContext = .middleOfSentence
            formatter.locale = Locale.current
            formatter.calendar = Calendar.current

            return formatter
        }()
        
        IntentPrediction(parameters: \.$date, displayRepresentation: { date in
            .init(stringLiteral: "Get timetable for \(namedRelativeFormatter.format(date))")
        })
    }
}

// Backwards compatability with pre-iOS 26
@available(*, deprecated)
extension GetTimetableIntent: ForegroundContinuableIntent {}
