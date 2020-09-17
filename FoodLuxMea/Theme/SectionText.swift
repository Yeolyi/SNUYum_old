//
//  SectionText.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Substitutes SwiftUI list section header
struct SectionText: ViewModifier {
    func body(content: Content) -> some View {
         HStack {
             content
                 .titleText()
                 .padding([.top, .bottom], 5)
                 .padding(.leading, 12)
             Spacer()
         }
    }
}

extension View {
    func sectionText() -> some View {
        return modifier(SectionText())
    }
}
