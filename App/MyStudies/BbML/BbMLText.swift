//
//  BbMLText.swift
//  My Brighton
//
//  Created by Neo Salmon on 03/11/2025.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit

fileprivate typealias ViewRepresentable = UIViewRepresentable
#elseif canImport(AppKit)
import AppKit

fileprivate typealias ViewRepresentable = NSViewRepresentable
#endif

struct BbMLText: ViewRepresentable {
    private let text: AttributedString

    init(_ text: AttributedString) {
        self.text = text
    }

    #if canImport(UIKit)
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView(frame: .zero)
        view.isScrollEnabled = false
        view.isEditable = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = UIColor.clear
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = NSAttributedString(text)
    }
    #endif

    #if canImport(AppKit)
    func makeNSView(context: Context) -> NSTextView {
        let view = NSTextView()
        view.isEditable = false
        view.drawsBackground = false
        view.textColor = .controlTextColor

        return view
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.textStorage?.setAttributedString(NSAttributedString(text))
        nsView.sizeToFit()
    }
    #endif
}

