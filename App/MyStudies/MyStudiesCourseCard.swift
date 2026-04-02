//
//  MyStudiesModuleCard.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import LearnKit
import CoreDesign
import CustomisationKit

struct MyStudiesCourseCard: View {
    @Environment(\.customisationService) private var customisationService

    @State private var course: Course
    @State private var customisations: CourseCustomisation

    init(course: Course) {
        self.course = course
        self.customisations = CourseCustomisation()
    }

    var body: some View {
        ZStack(alignment: customisations.textAlignment.swiftUIAlignment) {
            CustomisedBackgroundView(customisations.background)
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

            VStack(alignment: textRelativeHorizontalAlignment) {
                Text(course.courseId)
                    .font(customisations.fontDesign.swiftUIFont(.body))
                Text(customisations.displayNameOverride ?? course.name)
                    .font(customisations.fontDesign.swiftUIFont(.title3).bold())
                    .lineLimit(2)
                    .multilineTextAlignment(textRelativeTextAlignment)
            }
            .foregroundStyle(customisations.textColor.resolved)
            .scenePadding()
        }
        .overlay(alignment: favouriteButtonAlignment) {
            Button {
                customisations.isFavourite.toggle()
            } label: {
                Label("Mark as favourite", systemImage: customisations.isFavourite ? "star.fill" : "star")
                    .font(customisations.fontDesign.swiftUIFont(.body))
            }
            .buttonStyle(.borderless)
            .symbolEffect(.bounce, value: customisations.isFavourite)
            .imageScale(.large)
            .foregroundStyle(customisations.textColor.resolved)
            .labelStyle(.iconOnly)
            .sensoryFeedback(.success, trigger: customisations.isFavourite)
            .scenePadding()
        }
        .onAppear {
            self.customisations = customisationService.getCourseCustomisation(for: course.id)
        }
    }

    private var textRelativeHorizontalAlignment: HorizontalAlignment {
        switch customisations.textAlignment {
            case .topLeading, .centerLeading, .bottomLeading:
                return .leading
            case .top, .center, .bottom:
                return .center
            case .topTrailing, .centerTrailing, .bottomTrailing:
                return .trailing
            @unknown default:
                return .leading
        }
    }

    private var textRelativeTextAlignment: SwiftUI.TextAlignment {
        switch customisations.textAlignment {
            case .topLeading, .centerLeading, .bottomLeading:
                return .leading
            case .top, .center, .bottom:
                return .center
            case .topTrailing, .centerTrailing, .bottomTrailing:
                return .trailing
            @unknown default:
                return .leading
        }
    }

    private var favouriteButtonAlignment: Alignment {
        switch customisations.textAlignment {
            case .topLeading, .top, .topTrailing:
                return .bottomTrailing
            default:
                return .topTrailing
        }
    }

    private var aspectRatio: CGFloat {
        361 / 185
    }
}
