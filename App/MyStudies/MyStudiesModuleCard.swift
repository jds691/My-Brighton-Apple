//
//  MyStudiesModuleCard.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import Glur

// Fuck GeometryReader

struct MyStudiesModuleCard: View {
    let name: String
    let image: Module.Image
    let displayId: String
    
    @State private var isFavourite: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                ModuleImageView(image: image) { result in
                    result
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        //.glur(radius: 3.0)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(displayId)
                            .foregroundStyle(.white)
                        Text(name)
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
        .aspectRatio(aspectRatio, contentMode: .fit)
        /*.accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Class"))
        .accessibilityValue(Text("Class Name"))
        .accessibilityAddTraits(.isButton)*/
    }
    
    private var aspectRatio: CGFloat {
        361 / 185
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    // 20 seems to cause particular issue
    MyStudiesModuleCard(name: "VeryShort Module Name", image: .named("Thumbnails/nature20_thumb"), displayId: "CI001")
}
