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
    private let courseId: Course.ID
    private let courseName: String
    private let customisations: CourseCustomisation

    init(course: Course, customisations: CourseCustomisation) {
        self.courseId = course.courseId
        self.courseName = course.name
        self.customisations = customisations
    }

    init(courseId: Course.ID, name: String, customisations: CourseCustomisation) {
        self.courseId = courseId
        self.courseName = name
        self.customisations = customisations
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
                Text(courseId)
                    .font(customisations.fontDesign.swiftUIFont(.body))
                    .modifier(TextEffectsViewModifier(customisations.textEffects))
                Text(customisations.displayNameOverride ?? courseName)
                    .font(customisations.fontDesign.swiftUIFont(.title3).bold())
                    .modifier(TextEffectsViewModifier(customisations.textEffects))
                    .lineLimit(2)
                    .multilineTextAlignment(textRelativeTextAlignment)
            }
            .animation(.easeInOut, value: customisations.textAlignment)
            .foregroundStyle(customisations.textColor.resolved)
            .scenePadding()
        }
        .overlay(alignment: favouriteButtonAlignment) {
            Button {
                customisations.isFavourite.toggle()
            } label: {
                Label("Mark as favourite", systemImage: customisations.isFavourite ? "star.fill" : "star")
                    .font(customisations.fontDesign.swiftUIFont(.body))
                    .modifier(TextEffectsViewModifier(customisations.textEffects))
            }
            .buttonStyle(.borderless)
            .symbolEffect(.bounce, value: customisations.isFavourite)
            .imageScale(.large)
            .foregroundStyle(customisations.textColor.resolved)
            .labelStyle(.iconOnly)
            .sensoryFeedback(.success, trigger: customisations.isFavourite)
            .scenePadding()
            .animation(.easeInOut, value: customisations.textAlignment)
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
