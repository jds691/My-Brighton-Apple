//
//  CameraCaptureViewModifier.swift
//  CoreDesign
//
//  Created by Neo Salmon on 07/04/2026.
//

import SwiftUI
#if canImport(UIKit)
@available(iOS 13.0, macCatalyst 13.0, *)
@available(macOS, unavailable)
struct CameraCaptureViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var image: UIImage?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                CameraCaptureView(image: $image)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    @available(iOS 13.0, macCatalyst 13.0, *)
    @available(macOS, unavailable)
    public func cameraCapture(isPresented: Binding<Bool>, image: Binding<UIImage?>) -> some View {
        self.modifier(CameraCaptureViewModifier(isPresented: isPresented, image: image))
    }
}
#endif
