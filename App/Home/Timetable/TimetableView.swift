//
//  TimetableView.swift
//  My Brighton
//
//  Created by Neo Salmon on 30/08/2025.
//
//  Largely credited to: https://www.youtube.com/watch?v=sbheMzA3jTI
//

import SwiftUI
import Timetable
import TimetableUI
import TimetableIntents
import AppIntents
import os
import Router

// TODO: Adapt better for larger displays

struct TimetableViewDateButton: View {
    @Binding private var viewDate: Date
    private var date: Date

    let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"

        return formatter
    }()

    let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"

        return formatter
    }()

    init(viewDate: Binding<Date>, date: Date) {
        self._viewDate = viewDate
        self.date = date
    }

    var body: some View {
        Button {
            viewDate = date
        } label: {
            VStack {
                Text(dayNameFormatter.string(from: date))
                    .font(.callout.bold())
                    .foregroundStyle(.brightonSecondary)
                ZStack {
                    Circle()
                        .modifierBranch {
                            let isToday = date == .now.withoutTime

                            if viewDate == date {
                                if isToday {
                                    $0
                                        .foregroundStyle(.accent)
                                } else {
                                    $0
                                        .foregroundStyle(.brightonSecondary)
                                }
                            } else if isToday {
                                $0
                                    .strokeBorder(lineWidth: 3)
                                    .foregroundStyle(.accent)
                            } else {
                                $0
                                    .foregroundStyle(.brightonBackground)
                            }
                        }
                    Text(dayNumberFormatter.string(from: date))
                        .modifierBranch {
                            if viewDate == date {
                                $0
                                    .foregroundStyle(.white)
                            } else {
                                $0
                                    .foregroundStyle(.primary)
                            }
                        }
                }
                .frame(width: 40, height: 40)
            }
        }
        .buttonStyle(.plain)
    }
}

struct TimetableView: View {
    private static let logger: Logger = Logger(subsystem: "com.neo.My-Brighton", category: "TimetableView")
    @Environment(\.timetableService) private var timetableService

    @State private var currentDate: Date = .now.withoutTime
    @State private var weeks: [[IdentifiableDate]] = []
    @State private var weekScrollPosition: ScrollPosition
    private var weekIndex: Int {
        (weekScrollPosition.viewID as? Int) ?? 0
    }
    @State private var needsToCreateWeek: Bool = false
    @State private var classes: [ScheduledClass] = []

    @State private var showHeaderScrollButtons: Bool = false
    private var initialDate: Date?

    init() {
        weekScrollPosition = ScrollPosition(idType: Int.self)
        self.initialDate = nil
    }

    init(initialDate: Date?) {
        weekScrollPosition = ScrollPosition(idType: Int.self)
        self.initialDate = initialDate
    }

    var body: some View {
        ScrollView(.vertical) {
            Group {
                if classes.isEmpty {
                    ZStack {
                        Spacer()
                            .containerRelativeFrame([.vertical])

                        ContentUnavailableView("No Classes Today", systemImage: "calendar")
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        let isToday = currentDate == .now.withoutTime

                        if isToday {
                            let earlierClasses = classes.filter({ .now > $0.endDate })
                            let laterClasses = classes.filter({ $0.endDate >= .now })

                            if !earlierClasses.isEmpty {
                                Text("Earlier")
                                    .font(.title3.bold())
                                ForEach(earlierClasses, id: \.id) { scheduledClass in
                                    TimetableRowView(scheduledClass)
                                }
                                .padding(.bottom, 8)
                            }

                            if !laterClasses.isEmpty {
                                Text("Up Next")
                                    .font(.title3.bold())
                                TimetableRowView(laterClasses.first!, prominent: true)
                                    .padding(.bottom, 8)

                                let evenLaterClasses = laterClasses.dropFirst()
                                Text("Later")
                                    .font(.title3.bold())

                                if evenLaterClasses.isEmpty {
                                    NoContentView("Classes Finished for Today")
                                } else {
                                    ForEach(evenLaterClasses, id: \.id) { scheduledClass in
                                        TimetableRowView(scheduledClass)
                                    }
                                }
                            } else {
                                Text("Later")
                                    .font(.title3.bold())
                                NoContentView("Classes Finished for Today")
                            }
                        } else {
                            ForEach(classes, id: \.id) { scheduledClass in
                                TimetableRowView(scheduledClass)
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            do {
                try await timetableService.refresh()
                await refreshClassesForCurrentDate()
            } catch {
                Self.logger.error("Refresh eror: \(error)")
            }
        }
        .contentMargins(16, for: .scrollContent)
        .safeAreaInset(edge: .top) {
            header
        }
        .myBrightonBackground()
        .navigationTitle("Timetable")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .userActivity(UserActivity.Timetable.view) {
            let dateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                formatter.locale = Locale.current

                return formatter
            }()

            let identifierFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"

                return formatter
            }()

            $0.targetContentIdentifier = "timetable=\(identifierFormatter.string(from: currentDate))"
            $0.title = "Viewing timetable for \(dateFormatter.string(from: currentDate))"
            $0.webpageURL = URL(string: "https://timetablego.brighton.ac.uk/CMISGo/Web/Timetable")
            $0.isEligibleForHandoff = true
            $0.requiredUserInfoKeys = ["date"]
            $0.userInfo = [
                "date" : currentDate
            ]
        }
        .onContinueUserActivity(UserActivity.Timetable.view) { activity in
            guard let date = activity.userInfo?["date"] as? Date else {
                Self.logger.error("Failed to get date out of NSUserActivity")
                return
            }

            currentDate = date
            scrollToCurrentDate()
        }
        .onChange(of: weekIndex, initial: false) { old, new in
            if new == 0 || new == (weeks.count - 1) {
                needsToCreateWeek = true
            } else {
                needsToCreateWeek = false
            }
        }
        .onChange(of: currentDate) {
            Task {
                await refreshClassesForCurrentDate()
                try await IntentDonationManager.shared.donate(intent: GetTimetableIntent(date: currentDate))
            }
        }
        .task {
            // TODO: Check if all classes have ended for the day, if so show classes for tomorrow
            if weeks.isEmpty {
                let currentWeek = getWeekdaysForWeekOfMonth(from: .now)

                if let firstDate = currentWeek.first {
                    weeks.append(getWeekDaysForWeek(before: firstDate.date))
                }

                weeks.append(currentWeek)

                if let lastDate = currentWeek.last {
                    weeks.append(getWeekDaysForWeek(after: lastDate.date))
                }
            }

            if let initialDate {
                currentDate = initialDate
                scrollToCurrentDate()
            } else {
                currentDate = .now.withoutTime
                weekScrollPosition.scrollTo(id: 1)
            }

            Task {
                await refreshClassesForCurrentDate()
                try await IntentDonationManager.shared.donate(intent: GetTimetableIntent(date: currentDate))
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                #if os(macOS)
                Button {
                    // TODO: Eventually try to replace with environment refresh
                    Task {
                        do {
                            try await timetableService.refresh()
                            await refreshClassesForCurrentDate()
                        } catch {
                            Self.logger.error("Refresh eror: \(error)")
                        }
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: [.command])
                #endif

                Button("Today") {
                    currentDate = .now.withoutTime
                    scrollToCurrentDate()
                }
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        // TODO: Stops paging if the user scrolls too fast, resets when they let the view settle
        // https://github.com/users/jds691/projects/11/views/3?pane=issue&itemId=129421370
        ZStack {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(weeks.indices, id: \.self) { index in
                        HStack {
                            Spacer()
                            ForEach(weeks[index], id: \.self) { day in
                                TimetableViewDateButton(viewDate: $currentDate, date: day.date)
                                Spacer()
                            }
                        }
                        #if DEBUG
                        .overlay(alignment: .topLeading) {
                            Text("\(index)")
                                .bold()
                                .foregroundStyle(.red)
                        }
                        #endif
                        .onScrollVisibilityChange(threshold: 0.99) { visible in
                            if visible && (index == 0 || index == 2) {
                                Self.logger.debug("Middle page hidden")
                                Self.logger.debug("\(weekIndex)")

                                createPaginatedWeek()
                            }
                        }
                        .containerRelativeFrame(
                            [.horizontal], count: 1, spacing: 16
                        )
                        .tag(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition($weekScrollPosition)
            .scrollBounceBehavior(.basedOnSize)

            HStack {
                Button {
                    withAnimation {
                        weekScrollPosition.scrollTo(id: 0)
                    }
                } label: {
                    Label("Go to last week", systemImage: "chevron.left")
                }
                Spacer()
                Button {
                    withAnimation {
                        weekScrollPosition.scrollTo(id: 2)
                    }
                } label: {
                    Label("Go to next week", systemImage: "chevron.right")
                }
            }
            .imageScale(.large)
            .fontWeight(.bold)
            .labelStyle(.iconOnly)
            .foregroundStyle(.primary)
            .scenePadding()
            .containerRelativeFrame(
                [.horizontal], count: 1, spacing: 16
            )
            .allowsHitTesting(showHeaderScrollButtons)
            .opacity(showHeaderScrollButtons ? 1.0 : 0.0)
        }
        //.padding(.horizontal, 16)
        .background(.brightonBackground)
        .onHover { isHovering in
            showHeaderScrollButtons = isHovering
        }
    }

    private func scrollToCurrentDate() {
        // Date is currently on screen
        if weeks[weekIndex].contains(where: { $0.date == currentDate }) { return }

        if weeks[0].contains(where: { $0.date == currentDate }) {
            weekScrollPosition.scrollTo(id: 0)
            return
        } else if weeks[weeks.count - 1].contains(where: { $0.date == currentDate }) {
            weekScrollPosition.scrollTo(id: weeks.count - 1)
            return
        }

        if currentDate < weeks[0].first!.date {
            weeks[0] = getWeekdaysForWeekOfMonth(from: currentDate)
            weekScrollPosition.scrollTo(id: 0)
        } else if currentDate > weeks[weeks.count - 1].last!.date {
            weeks[weeks.count - 1] = getWeekdaysForWeekOfMonth(from: currentDate)
            weekScrollPosition.scrollTo(id: weeks.count - 1)
        }
    }

    private func refreshClassesForCurrentDate() async {
        do {
            classes = try await timetableService.getClasses(after: currentDate)
        } catch {
            Self.logger.error("Error refreshing classes for current date: \(error)")
        }
    }

    func getWeekdaysForWeekOfMonth(from date: Date) -> [IdentifiableDate] {
        let calendar = Calendar.current
        let startOfDate = date.withoutTime

        var week: [IdentifiableDate] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else { return [] }

        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay.withoutTime))
            }
        }

        return week
    }

    func getWeekDaysForWeek(after date: Date) -> [IdentifiableDate] {
        let calendar = Calendar.current
        let startOfLastDate = date.withoutTime
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }

        return getWeekdaysForWeekOfMonth(from: nextDate)
    }

    func getWeekDaysForWeek(before date: Date) -> [IdentifiableDate] {
        let calendar = Calendar.current
        let startOfLastDate = date.withoutTime
        guard let nextDate = calendar.date(byAdding: .day, value: -1, to: startOfLastDate) else {
            return []
        }

        return getWeekdaysForWeekOfMonth(from: nextDate)
    }

    func createPaginatedWeek() {
        createPaginatedWeek(for: weeks[weekIndex])
    }

    func createPaginatedWeek(for week: [IdentifiableDate]) {
        if week.indices.contains(weekIndex) {
            if let firstDate = week.first, weekIndex == 0 {
                weeks.insert(getWeekDaysForWeek(before: firstDate.date), at: 0)
                weeks.removeLast()

                weekScrollPosition.scrollTo(id: 1)
            }

            if let lastDate = week.last, weekIndex == 2 {
                weeks.append(getWeekDaysForWeek(after: lastDate.date))
                weeks.removeFirst()

                weekScrollPosition.scrollTo(id: 1)
            }
        }
    }

    struct IdentifiableDate: Identifiable, Hashable {
        var id: UUID = UUID()
        var date: Date
    }
}

#Preview(traits: .timetableService) {
    TabView {
        Tab {
            NavigationStack {
                TimetableView()
            }
        }
    }
    .tabViewStyle(.sidebarAdaptable)
}
