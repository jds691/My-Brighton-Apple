//
//  OnboardingView.swift
//  My Brighton
//
//  Created by Neo Salmon on 01/05/2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var canShowContentView: Bool

    @available(macOS 15.0, *)
    init() {
        self._canShowContentView = .constant(false)
    }

    @available(iOS 18.0, *)
    init(canShowContentView: Binding<Bool>?) {
        if let canShowContentView {
            self._canShowContentView = canShowContentView
        } else {
            self._canShowContentView = .constant(false)
        }
    }

    var body: some View {
        Text("Getting on that board fr fr")
    }
}
