//
//  CafeMaterial.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/26.
//

import SwiftUI

/// Determines how single cafe data displayed.
///
/// Includes information about if cafe is fixed and shown.
///
/// - Important: There always should be corresponding ListElement for each cafe data in DataManager.
///
/// - Note: Default value is unfixed.
struct CafeMaterial: Hashable, Codable, Identifiable {
    var id = UUID()
    /// Cafe's name
    var name: String = ""
    /// Always show cafe on the top of the list
    var isFixed: Bool = false
    /// Show cafe in list
    var isShown: Bool = true
}
