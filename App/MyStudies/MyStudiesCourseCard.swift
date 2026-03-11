//
//  MyStudiesModuleCard.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import LearnKit

// Fuck GeometryReader

struct MyStudiesCourseCard: View {
    @State private var course: Course

    @State private var isFavourite: Bool = false

    init(course: Course) {
        self.course = course
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .aspectRatio(contentMode: .fill)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .foregroundStyle(.brightonSecondary)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))

            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(course.courseId)
                        .foregroundStyle(.white)
                    Text(course.name)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Button {
                    isFavourite.toggle()
                } label: {
                    Label("Mark as favourite", systemImage: isFavourite ? "star.fill" : "star")
                }
                .buttonStyle(.borderless)
                .symbolEffect(.bounce, value: isFavourite)
                .imageScale(.large)
                .foregroundStyle(.white)
                .labelStyle(.iconOnly)
                .sensoryFeedback(.success, trigger: isFavourite)
            }
            .scenePadding()
        }
    }
    
    private var aspectRatio: CGFloat {
        361 / 185
    }
}
