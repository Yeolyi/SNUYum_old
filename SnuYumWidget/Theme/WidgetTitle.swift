//
//  WidgetTitle.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import SwiftUI

struct WidgetTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(20), weight: .bold, design: .default))
    }
}

extension View {
    func widgetTitle() -> some View {
        return modifier(WidgetTitle())
    }
}
