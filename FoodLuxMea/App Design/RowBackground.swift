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
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.05))
                .cornerRadius(10)
        }
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom], 3)
    }
}

extension View {
    func rowBackground() -> some View {
        return modifier(RowBackground())
    }
}

/// Cornered list row background
struct AccentedRowBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        Group {
            content
                .padding(10)
                .background(ThemeColor().title(colorScheme).opacity(0.15))
                .cornerRadius(10)
        }
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom], 3)
    }
}

extension View {
    func optionalRowBackground(isAccented: Bool) -> AnyView {
        if isAccented {
            return AnyView(modifier(AccentedRowBackground()))
        } else {
            return AnyView(modifier(RowBackground()))
        }
    }
}
