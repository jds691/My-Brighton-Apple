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

fileprivate struct BbMLTextInterior: ViewRepresentable {
    private let text: AttributedString
    @Binding
    private var height: CGFloat

    init(_ text: AttributedString, height: Binding<CGFloat>) {
        self.text = text
        self._height = height
    }

    #if canImport(UIKit)
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isScrollEnabled = false
        view.isEditable = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = UIColor.clear
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)

        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            uiView.attributedText = NSAttributedString(text)

            let fixedWidth = uiView.frame.size.width
            let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

            self.height = newSize.height
        }
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

struct BbMLText: View {
    @State private var height: CGFloat = .zero
    private let text: AttributedString

    init(_ text: AttributedString) {
        self.text = text
    }

    var body: some View {
        BbMLTextInterior(text, height: $height)
            .frame(height: height)
    }
}

