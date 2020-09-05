//
//  ThemeColor.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI



class ThemeColor: ObservableObject {

    private var colorTitleDark = Color(hex: "#6F77A6")
    private var colorTitleLight = Color(hex: "#3B568C")

    private var colorIconLight = Color(hex: "#3F4D59")
    private var colorIconDark = Color(hex: "#7B848C")
    
    func colorIcon(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? colorIconDark : colorIconLight
    }
    func colorTitle(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? colorTitleDark : colorTitleLight
    }
    func tempColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "#F2D225") : Color(hex: "F26A4B")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
