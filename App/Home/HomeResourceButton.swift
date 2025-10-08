//
//  HomeResourceButton.swift
//  My Brighton
//
//  Created by Neo on 05/09/2023.
//

import SwiftUI

struct HomeResourceButton<Label: View>: View {
    @Environment(\.openURL) private var openURL

    private var resourceURL: URL?
    @State private var action: () -> Void
    private var label: () -> Label

    init(action: @escaping () -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    init(url: URL, label: @escaping () -> Label) {
        self.resourceURL = url
        self.action = {}
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            label()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(.yellow)
        .foregroundStyle(.black)
        .buttonStyle(.borderedProminent)
        .onAppear {
            if let resourceURL {
                self.action = { openURL(resourceURL) }
            }
        }
    }
}

#Preview {
    HomeResourceButton {
        
    } label: {
        Label("Book a Computer", systemImage: "display")
    }
    .scenePadding()
}
