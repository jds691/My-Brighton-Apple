//
//  HomeHeaderView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/09/2025.
//

import SwiftUI

struct HomeHeaderView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        //Color("Theme/2021/Green")
        Image(decorative: "StudentIdBanner")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottom)
            .clipped()
            .headerBlur()
            .modifierBranch {
                if #available(iOS 26, macOS 26, *) {
                    $0
                        .backgroundExtensionEffect()
                } else {
                    $0
                }
            }
            .overlay(alignment: .bottomLeading) {
                HStack {
                    Circle()
                        .frame(width: 80, height: 80)
                    VStack(alignment: .leading, spacing: 8) {
                        TimelineView(.everyMinute) { context in
                            // TODO: Replace with users preferred name
                            Text("\(timeOfDayString(context.date)), Neo!")
                                .font(.largeTitle.bold())
                        }
                        Text("No new updates")
                    }

                }
                .foregroundStyle(.white)
                .scenePadding()
                .padding(.bottom, 16)
            }
    }

    private func timeOfDayString(_ date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)

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

#Preview {
    HomeHeaderView()
}
