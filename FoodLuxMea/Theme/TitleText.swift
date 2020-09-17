//
//  TitleText.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

/// Modifier for highlight-needing important text
struct TitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(18), weight: .medium, design: .default))
    }
}


extension View {
    func titleText() -> some View {
        return modifier(TitleText())
    }
}

struct TitleText_Previews: PreviewProvider {
    static var previews: some View {
        Text("왜안대")
            .titleText()
    }
}
