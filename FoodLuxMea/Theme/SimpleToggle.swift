//
//  iOS1314Toggle.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/25.
//

import SwiftUI

/// Custom toggle with static images.
struct SimpleToggle: View {
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    @Binding var isOn: Bool
    let label: String
    
    /**
     - Parameters:
     - isOn: Passes toggle value to parent view
     - label: String to show next to toggle
     */
    init(isOn: Binding<Bool>, label: String) {
        self._isOn = isOn
        self.label = label
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: isOn ? "checkmark" : "xmark")
                .offset(x: -5)
                .foregroundColor(themeColor.icon(colorScheme))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.isOn.toggle()
        }
    }
}
