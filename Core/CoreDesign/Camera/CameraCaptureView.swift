//
//  CameraCaptureView.swift
//  CoreDesign
//
//  Created by Neo Salmon on 29/08/2021.
//
// Source code taken from an old UIKit+AppKit bridging framework for SwiftUI I made, KitToSwift.
// Therefore I own the license for this old code. However, this is a modified version of it.

#if canImport(UIKit)
import SwiftUI

/// Provides a view for capturing photos with the system camera.
@available(iOS 13.0, macCatalyst 13.0, *)
struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    public init(image: Binding<UIImage?>) {
        self._image = image
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image, dismissAction: { dismiss() })
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var image: UIImage?
        var dismiss: (() -> Void)

        init (image: Binding<UIImage?>, dismissAction: @escaping () -> Void) {
            self._image = image
            self.dismiss = dismissAction
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            dismiss()
            image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

/*fileprivate extension UIImage {
    func _fixOrientation() -> UIImage? {
        guard imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
*/
#endif
