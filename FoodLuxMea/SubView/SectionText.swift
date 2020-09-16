//
//  SectionText.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// ViewModifier which substitutes SwiftUI list section header
struct SectionText: ViewModifier {
    func body(content: Content) -> some View {
        content
        .font(.system(size: CGFloat(20), weight: .semibold, design: .default))
        .foregroundColor(.primary)
    }
}
