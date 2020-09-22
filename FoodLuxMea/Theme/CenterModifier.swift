//
//  CenterModifier.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/22.
//

import SwiftUI

/// Cornered list row background
struct Centered: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

extension View {
    func centered() -> some View {
        return modifier(Centered())
    }
}
