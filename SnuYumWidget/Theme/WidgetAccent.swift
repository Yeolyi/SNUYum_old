//
//  WidgetAccent.swift
//  SnuYumWidgetExtension
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import SwiftUI

struct WidgetAccent: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(15), weight: .semibold, design: .default))
            .foregroundColor(themeColor.title(colorScheme))
            .lineLimit(1)
    }
}

extension View {
    func widgetAccent() -> some View {
        return modifier(WidgetAccent())
    }
}
