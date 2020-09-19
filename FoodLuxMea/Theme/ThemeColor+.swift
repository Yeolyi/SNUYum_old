//
//  ThemeColor.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Provides title and icon color based on ColorScheme.
class ThemeColor: ObservableObject {
  
  private var titleDark = Color(hex: "#6F77A6")
  private var titleLight = Color(hex: "#3B568C")
  
  private var iconLight = Color(hex: "#3F4D59")
  private var iconDark = Color(hex: "#7B848C")
  
  func icon(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? iconDark : iconLight
  }
  
  func title(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? titleDark : titleLight
  }
  
}

extension Color {
  
  /// Changes hex string(e.g. "#6F77A6") to color
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
