//
//  SwiftUIView.swift
//  
//
//  Created by Neo Salmon on 11/12/2021.
//

#if canImport(EventKitUI)
import SwiftUI
import EventKitUI

@available(iOS 13, macCatalyst 13, *)
public struct EventEditView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var event: EKEvent?
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(dismissAction: dismiss)
    }
    
    public func makeUIViewController(context: Context) -> EKEventEditViewController {
        let vc = EKEventEditViewController()
        vc.event = event
        vc.editViewDelegate = context.coordinator
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) { }
    
    public class Coordinator: NSObject, EKEventEditViewDelegate {
        let dismiss: DismissAction

        public init(dismissAction: DismissAction) {
            self.dismiss = dismissAction
        }
        
        public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            dismiss()
        }
    }
}

extension EventEditView {
    //MARK: - Initializers
    public init(_ event: EKEvent?) {
        self.event = event
    }
}
#endif
