//
//  TimetableHomeWidgetView.swift
//  My Brighton
//
//  Created by Neo Salmon on 30/08/2025.
//

import SwiftUI
import Timetable
import Router
import CoreDesign

struct TimetableHomeWidgetView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(Router.self) private var router
    @Environment(\.timetableService) private var timetableService

    @AppStorage(TimetableService.remoteURLUserDefaultsKey) private var timetableURL: URL?

    @State private var hadClassesToday: Bool = false
    @State private var classes: [ScheduledClass] = []
    @State private var isLoading: Bool = true
    @State private var currentDisplayDate: Date

    private var startDateOverride: Date?

    private var upcomingOrCurrentClasses: [ScheduledClass] {
        classes.filter({ currentDisplayDate <= $0.endDate })
    }

    init() {
        self.startDateOverride = nil
        self.currentDisplayDate = .now
    }

    init(for date: Date) {
        self.startDateOverride = date
        self.currentDisplayDate = date
    }

    var body: some View {
        Button {
            if startDateOverride != nil || timetableService.canFetchTimetable {
#if os(macOS)
                openWindow(id: "timetable")
#else
                router.appendToPath(.timetable(nil))
#endif
            } else {
                router.navigate(to: .modal(.timetableSetup))
            }

        } label: {
            VStack(alignment: .leading, spacing: 8) {
                header
                if startDateOverride != nil || timetableService.canFetchTimetable {
                    initialisedWidget
                } else {
                    NoContentView {
                        Label("Setup Timetable", systemImage: "calendar")
                            .foregroundStyle(.accent)
                    }
                }

            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Text("Today's Classes")
                .font(.title3.bold())
            Image(systemName: "chevron.forward")
                .foregroundStyle(.brightonSecondary)
                .imageScale(.large)
                .fontWeight(.bold)
            #if DEBUG
            if let startDateOverride {
                Text("Override: \(startDateOverride.description)")
                    .foregroundStyle(.brightonSecondary)
            }
            #endif
        }
    }

    @ViewBuilder
    fileprivate var initialisedWidget: some View {
        TimelineView(.everyMinute) { context in
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                        .background(.brightonBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .circular)
                                .strokeBorder(lineWidth: 3, antialiased: true)
                        }
                } else if upcomingOrCurrentClasses.isEmpty {
                    if hadClassesToday {
                        NoContentView("Classes Finished for Today")
                    } else {
                        NoContentView("No Classes Today")
                    }
                } else {
                    VStack(alignment: .leading) {
                        ForEach(upcomingOrCurrentClasses, id: \.id) { scheduledClass in
                            TimetableRowView(scheduledClass)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.brightonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .circular))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .strokeBorder(lineWidth: 3, antialiased: true)
                    }
                }
            }
            .task(id: context.date) {
                do {
                    // isLoading is not reset to true otherwise it causes infinite calls
                    currentDisplayDate = startDateOverride ?? context.date
                    classes = try await timetableService.getClasses(after: startDateOverride?.withoutTime ?? context.date.withoutTime)
                    hadClassesToday = classes.count > 0
                    isLoading = false
                } catch {
                }
            }
        }
    }
}

#Preview("No Classes", traits: .sizeThatFitsLayout, .environmentObjects, .timetableService) {
    TimetableHomeWidgetView().initialisedWidget
}


#Preview("Classes", traits: .sizeThatFitsLayout, .environmentObjects, .timetableService) {
    let date: Date = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = .init(identifier: "GMT")
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: "2025-09-29T00:00:00")! // replace Date String
    }()

    TimetableHomeWidgetView(for: date).initialisedWidget
}
