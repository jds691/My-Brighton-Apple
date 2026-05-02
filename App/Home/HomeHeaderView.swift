//
//  HomeHeaderView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/09/2025.
//

import Foundation
import SwiftUI
import CustomisationKit
import CoreDesign

struct HomeHeaderView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accountService) private var accountService

    @Binding var customisations: HomeCustomisation
    var opaqueBlur: Bool

    @State private var realName: String = ""

    init(customisations: Binding<HomeCustomisation>, opaqueBlur: Bool) {
        self._customisations = customisations
        self.opaqueBlur = opaqueBlur
    }

    var body: some View {
        CustomisedBackgroundView(customisations.background)
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottom)
            .clipped()
            .homeHeaderBlur(customisations: customisations, opaque: opaqueBlur)
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
                    AsyncImage(url: customisations.profilePictureOverrideUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.brightonSecondary
                    }
                    .accessibilityHidden(true)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .padding(3)
                    .overlay {
                        Circle()
                            .strokeBorder(lineWidth: 3, antialiased: true)
                            .foregroundStyle(customisations.textColor.resolved)
                    }
                    .modifier(TextEffectsViewModifier(customisations.textEffects))
                    
                    TimelineView(.everyMinute) { context in
                        Text("\(timeOfDayString(context.date)), \(customisations.displayNameOverride ?? realName)!")
                            .font(customisations.fontDesign.swiftUIFont(.largeTitle).bold())
                            .modifier(TextEffectsViewModifier(customisations.textEffects))
                    }
                }
                .foregroundStyle(customisations.textColor.resolved)
                .scenePadding()
                .padding(.bottom, 16)
            }
            .onAppear {
                if let fullName = try? accountService.getAccountDetails().fullName {
                    realName = String(fullName.split(separator: " ").first ?? "")
                }
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
    ScrollView {
        HomeHeaderView(customisations: .constant(HomeCustomisation()), opaqueBlur: false)
            .flexibleHeaderContent()
    }
    .flexibleHeaderScrollView()
    .ignoresSafeArea(edges: .top)
}
