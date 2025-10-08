//
//  NewsCarrosselView.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI

struct NewsCarrosselView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: hSpacing) {
                ForEach(1...10, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.brightonSecondary)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .containerRelativeFrame(
                            [.horizontal], count: containerFrameCount, spacing: 16
                        )
                }
            }
            .fixedSize()
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
    }
    
    private var hSpacing: CGFloat {
        16
    }
    
    private var aspectRatio: CGFloat {
        358 / 185
    }
    
    private var containerFrameCount: Int {
        hSizeClass == .compact ? 1 : 2
    }
}

#Preview {
    NewsCarrosselView()
        .contentMargins(16, for: .scrollContent)
}
