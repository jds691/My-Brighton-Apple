//
//  ViewModifier+DesignSystemAwareLabelStyle.swift
//  My Brighton
//
//  Created by Neo Salmon on 21/06/2025.
//

import SwiftUI

public struct DesignSystemAwareLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26, macOS 26, *) {
            configuration.icon
        } else {
            configuration.title
        }
    }
}

extension LabelStyle where Self == DesignSystemAwareLabelStyle {
    public static var designSystemAware: DesignSystemAwareLabelStyle {
        DesignSystemAwareLabelStyle()
    }
}
