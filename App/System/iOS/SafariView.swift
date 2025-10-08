//
//  SafariView.swift
//  My Brighton
//
//  Created by Neo on 05/09/2023.
//

import SwiftUI
import SafariServices

@available(iOS, deprecated: 26.0, message: "OS 26 supports opening web views inline with OpenURLAction")
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = UIColor(Color.accentColor)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

#Preview {
    SafariView(url: URL(string: "https://apple.com")!)
        .ignoresSafeArea()
}
