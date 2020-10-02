//
//  Subtitle.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import SwiftUI

struct WidgetSubtitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(15), weight: .semibold, design: .default))
            .fixedSize()
            .lineLimit(1)
    }
}

extension View {
    func widgetSubtitle() -> some View {
        return modifier(WidgetSubtitle())
    }
}
