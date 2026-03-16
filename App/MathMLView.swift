//
//  WKWebViewTest.swift
//  My Brighton
//
//  Created by Neo Salmon on 05/07/2025.
//

import SwiftUI
import WebKit

#if os(iOS)
fileprivate typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
fileprivate typealias ViewRepresentable = NSViewRepresentable
#endif

fileprivate struct MathMLInteriorView: ViewRepresentable {
    @Binding var dynamicHeight: CGFloat
    @Binding var dynamicWidth: CGFloat
    @Binding var needsRefresh: Bool

    var targetWidth: CGFloat
    var mathML: String
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MathMLInteriorView
        
        init(_ parent: MathMLInteriorView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                if let error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        self.parent.dynamicHeight = height as! CGFloat
                    }
                }
            })
            
            webView.evaluateJavaScript("document.body.scrollWidth", completionHandler: { (height, error) in
                if let error {
                    print(error)
                } else {
                    DispatchQueue.main.async {
                        self.parent.dynamicWidth = height as! CGFloat
                    }
                }
            })
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        #if os(iOS)
        view.scrollView.isScrollEnabled = false
        view.scrollView.delegate = context.coordinator
        #endif
        view.navigationDelegate = context.coordinator

        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(
            """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES">
                <link href="MathMLView.css" rel="stylesheet">
            </head>
            <body style="width: \(targetWidth)px;">
            <math display="block">
            \(mathML)
            </math>
            </body>
            </html>
            """,
            baseURL: #bundle.bundleURL
        )
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView()
        
        view.navigationDelegate = context.coordinator
        view.loadHTMLString(
            """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES">
                <link href="MathMLView.css" rel="stylesheet">
            </head>
            <body style="width: \(targetWidth)px;">
            <math display="block">
            \(mathML)
            </math>
            </body>
            </html>
            """,
            baseURL: #bundle.bundleURL
        )

        return view
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(
            """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES">
                <link href="MathMLView.css" rel="stylesheet">
            </head>
            <body style="width: \(targetWidth)px;">
            <math display="block">
            \(mathML)
            </math>
            </body>
            </html>
            """,
            baseURL: #bundle.bundleURL
        )
    }
}

#if os(iOS)
extension MathMLInteriorView.Coordinator: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
#endif

struct MathMLView: View {
    @State private var height: CGFloat = .zero
    @State private var width: CGFloat = .zero

    @State private var refreshWebViewFlag: Bool = false

    var mathML: String
    var altText: LocalizedStringResource? = nil

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                if height == .zero || width == .zero {
                    HStack(alignment: .center) {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
                MathMLInteriorView(dynamicHeight: $height, dynamicWidth: $width, needsRefresh: $refreshWebViewFlag, targetWidth: proxy.size.width, mathML: mathML)
                    .frame(height: height)
            }
        }
        .frame(height: height == 0 ? 53 : height, alignment: .center)
        #if DEBUG
        .contextMenu {
            Section("Debug") {
                Button {
                    height = .zero
                    width = .zero
                    refreshWebViewFlag.toggle()
                } label: {
                    Label("Refresh WKWebView", systemImage: "arrow.clockwise")
                }
            }

        }
        #endif
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Mathametics Markup"))
        .accessibilityValue(altText != nil ? Text(altText!) : Text(""))
        .accessibilityAddTraits([.isStaticText])
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MathMLView(
        mathML:
                """
            <mrow>
            <mi>x</mi>
            <mo>=</mo>
            <mfrac>
            <mrow>
            <mrow>
            <mo>−</mo>
            <mi>b</mi>
            </mrow>
            <mo>±</mo>
            <msqrt>
            <mrow>
            <msup>
              <mi>b</mi>
              <mn>2</mn>
            </msup>
            <mo>−</mo>
            <mrow>
              <mn>4</mn>
              <mo>⁢</mo>
              <mi>a</mi>
              <mo>⁢</mo>
              <mi>c</mi>
            </mrow>
            </mrow>
            </msqrt>
            </mrow>
            <mrow>
            <mn>2</mn>
            <mo>⁢</mo>
            <mi>a</mi>
            </mrow>
            </mfrac>
            </mrow>
            """,
        altText: .init(stringLiteral: "x equals fraction start, negative b plus or minus square root of b squared minus 4 a c, end of root, over 2 a, end of fraction, maths")
    )
}
