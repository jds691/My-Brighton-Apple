//
//  SplitStack.swift
//  My Brighton
//
//  Created by Neo on 28/10/2023.
//

import SwiftUI

//REVIEW: What in the ever living hell did I do

struct SplitStack<ProminentContent: View, SecondaryContent: View>: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    private var horiztontalAlignment: HorizontalAlignment
    private var verticalAlignment: VerticalAlignment
    private var splitSpacing: CGFloat?
    private var stackReverseMode: StackReverseMode
    private var prominentContent: () -> ProminentContent
    private var secondaryContent: () -> SecondaryContent
    
    init(
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .top,
        splitSpacing: CGFloat? = nil,
        reverse: StackReverseMode = .none,
        @ViewBuilder
        prominentContent: @escaping () -> ProminentContent,
        @ViewBuilder
        secondaryContent: @escaping () -> SecondaryContent
    ) {
        self.horiztontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.splitSpacing = splitSpacing
        self.stackReverseMode = reverse
        self.prominentContent = prominentContent
        self.secondaryContent = secondaryContent
    }
    
    var body: some View {
        if hSizeClass == .compact {
            VStack(alignment: self.horiztontalAlignment, spacing: self.splitSpacing, content: {
                if stackReverseMode == .vertical || stackReverseMode == .both {
                    secondaryContent()
                    prominentContent()
                } else {
                    prominentContent()
                    secondaryContent()
                }
                
            })
        } else if hSizeClass == .regular {
            HStack(
                alignment: self.verticalAlignment,
                spacing: splitSpacing) {
                    if stackReverseMode == .horizontal || stackReverseMode == .both {
                        secondaryContent()
                        prominentContent()
                    } else {
                        prominentContent()
                        secondaryContent()
                    }
                }
        } else {
            Text("Stack configuration unknown.")
        }
    }
    
    public enum StackReverseMode {
        case none, vertical, horizontal, both
    }
}

#Preview {
    SplitStack(horizontalAlignment: .leading) {
        Text("This is standalone!")
    } secondaryContent: {
        Text("This is not...")
    }
}
