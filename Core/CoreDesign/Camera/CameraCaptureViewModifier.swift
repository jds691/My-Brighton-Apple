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

    private let preferredCamera: PreferredCamera

    public init(isPresented: Binding<Bool>, image: Binding<UIImage?>, preferredCamera: PreferredCamera) {
        self._isPresented = isPresented
        self._image = image
        self.preferredCamera = preferredCamera
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                CameraCaptureView(image: $image)
                    .ignoresSafeArea()
            }
    }
}

public enum PreferredCamera {
    case rear
    case front

    var uiImagePickerControllerCameraDevice: UIImagePickerController.CameraDevice {
        switch self {
            case .rear:
                return .rear
            case .front:
                return .front
        }
    }
}

extension View {
    @available(iOS 13.0, macCatalyst 13.0, *)
    @available(macOS, unavailable)
    public func cameraCapture(isPresented: Binding<Bool>, image: Binding<UIImage?>, preferredCamera: PreferredCamera = .rear) -> some View {
        self.modifier(CameraCaptureViewModifier(isPresented: isPresented, image: image, preferredCamera: preferredCamera))
    }
}
#endif
