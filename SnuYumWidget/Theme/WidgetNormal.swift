//
//  WidgetNormal.swift
//  SnuYumWidgetExtension
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import SwiftUI

struct WidgetNormal: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(15), weight: .regular, design: .default))
            .foregroundColor(.secondary)
            .lineLimit(1)
    }
}

extension View {
    func widgetNormal() -> some View {
        return modifier(WidgetNormal())
    }
}
