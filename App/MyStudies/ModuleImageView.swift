//
//  ModuleImageView.swift
//  My Brighton
//
//  Created by Neo Salmon on 29/06/2025.
//

import SwiftUI

struct ModuleImageView<ImageResult: View>: View {
    let image: Module.Image
    let modifiers: (Image) -> ImageResult
    
    public init(image: Module.Image, @ViewBuilder modifiers: @escaping (Image) -> ImageResult = { $0 }) {
        self.image = image
        self.modifiers = modifiers
    }
    
    var body: some View {
        switch image {
            case .named(let imageName):
                modifiers(Image(imageName))
            case .remote(url: let url):
                // URL(string: "https://ultra.content.blackboardcdn.com/ultra/static/images/default-banners/nature16_thumb.jpg")!
                AsyncImage(url: url, content: { image in
                    modifiers(image)
                    //.scaledToFill()
                    /*.frame(maxWidth: .infinity, minHeight: 185, alignment: .bottomLeading)
                     .aspectRatio(aspectRatio, contentMode: .fit)*/
                }, placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.brightonSecondary)
                })
        }
    }
}

#Preview("Named Image", traits: .sizeThatFitsLayout) {
    ModuleImageView(image: .named("Thumbnails/nature20_thumb")) {
        $0
            .resizable()
            .aspectRatio(2, contentMode: .fit)
    }
}

#Preview("Remote Image", traits: .sizeThatFitsLayout) {
    ModuleImageView(image: .remote(url: URL(string: "https://ultra.content.blackboardcdn.com/ultra/static/images/default-banners/nature16_thumb.jpg")!)) {
        $0
            .resizable()
            .aspectRatio(2, contentMode: .fit)
    }
}
