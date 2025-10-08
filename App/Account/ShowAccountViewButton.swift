//
//  ShowAccountViewButton.swift
//  My Brighton
//
//  Created by Neo on 25/08/2023.
//

import SwiftUI
import Router

struct ShowAccountViewButton: View {
    @Environment(Router.self) private var router: Router
    
    var body: some View {
        Button {
            router.navigate(to: .modal(.account))
        } label: {
            Label("Account", systemImage: "person.crop.circle")
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview(traits: .environmentObjects) {
    ShowAccountViewButton()
}
