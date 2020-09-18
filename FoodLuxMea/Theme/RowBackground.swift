//
//  ListRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/18.
//

import SwiftUI

/// Cornered list row background
struct RowBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        Group {
            content
                .padding(10)
                .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.gray.opacity(0.05))
                .cornerRadius(10)
        }
        .padding([.top, .bottom], 2)
        .padding([.leading, .trailing], 10)
    }
}

extension View {
    func rowBackground() -> some View {
        return modifier(RowBackground())
    }
}
