//
//  ModuleDiscussionsScrollView.swift
//  My Brighton
//
//  Created by Neo Salmon on 27/08/2025.
//

import SwiftUI
import CoreDesign
import Router

struct ModuleDiscussionsScrollView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(value: Navigation.Route.MyStudiesSubRoute.ModuleSubRoute.discussions(nil)) {
                HStack {
                    Text("Recent Discussions")
                        .font(.title3.bold())
                    Image(systemName: "chevron.forward.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .brightonSecondary)
                        .imageScale(.large)
                }

            }
            .buttonStyle(.plain)

            NoContentView("No Recent Discussions")
                .frame(minHeight: 80)
        }
    }

    private var containerFrameSpan: Int {
        hSizeClass == .compact ? 5 : 2
    }
}

#Preview {
    ModuleDiscussionsScrollView()
        .scenePadding()
        .scrollClipDisabled()
}
