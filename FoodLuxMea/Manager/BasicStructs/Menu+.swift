//
//  Menu+.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/20.
//

import Foundation

/// Indicates one of these three meals; breakfast, lunch and dinner.
///
/// Support raw string value in korean.
///
/// - Note: Codable protocol adopted to encoded/decoded while using Userdefault.
enum MealType: String, Codable {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
}

/// Data of a single menu.
///
/// If there's no cost data in server, cost value is -1.
///
/// - Precondition: 'cost' variable cannot be negative other than -1.
///
/// - Note: Hashable protocol to make Menu array.
///
/// Codable protocol to encoded/decoded while using Userdefault.
///
/// Identifiable adopted to give id in list view.
///
/// - Todo: Change cost type to optional Int to stop using -1.
struct Menu: Hashable, Codable, Identifiable {
    var id = UUID()
    let name: String
    let cost: Int
    
    /**
     Creates an menu struct.
     
     - Parameter cost: Defult value is -1.
     */
    init(name: String, cost: Int = -1) {
        self.name = name
        guard cost >= 0 || cost == -1 else {
            assertionFailure("Menu/init: Inappropriate cost value - \(cost)")
            self.cost = -1
            return
        }
        self.cost = cost
    }
}
