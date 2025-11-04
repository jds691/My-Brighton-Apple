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

    @available(iOS 18, *)
    init(_ text: AttributedString, height: Binding<CGFloat>) {
        self.text = text
        self._height = height
    }

    @available(macOS 15, *)
    init(_ text: AttributedString) {
        self.text = text
        self._height = .constant(0)
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
        let view = InternalTextView()
        view.isEditable = false
        view.drawsBackground = false
        view.usesAdaptiveColorMappingForDarkAppearance = true
        view.textColor = .controlTextColor
        view.font = NSFont.preferredFont(forTextStyle: .body)
        view.isRichText = true
        view.isVerticallyResizable = false
        view.isHorizontallyResizable = false

        view.textStorage?.setAttributedString(NSMutableAttributedString(text))

        return view
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
    }

    // FML: https://stackoverflow.com/q/74045727
    class InternalTextView: NSTextView {
        init() {
            super.init(frame: NSRect.zero)
            setContentHuggingPriority(.defaultHigh, for: .vertical)
        }

        override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
            super.init(frame: frameRect, textContainer: container)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layout() {
            invalidateIntrinsicContentSize()
            super.layout()
        }

        override var intrinsicContentSize: NSSize {
            layoutManager!.ensureLayout(for: textContainer!)
            return CGSize(width: -1.0, height: ceil(layoutManager!.usedRect(for: textContainer!).size.height))
        }
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
        #if os(iOS)
        BbMLTextInterior(text, height: $height)
            .frame(height: height)
        #elseif os(macOS)
        BbMLTextInterior(text)
        #endif
    }
}

