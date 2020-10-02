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
    
    static func next(meal: MealType) -> MealType {
        switch meal {
        case .breakfast: return .lunch
        case .lunch: return .dinner
        case .dinner: return .breakfast
        }
    }
    static func previous(meal: MealType) -> MealType {
        switch meal {
        case .breakfast: return .dinner
        case .lunch: return .breakfast
        case .dinner: return .lunch
        }
    }
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
    let cost: Int?
    
    /**
     Creates an menu struct.
     
     - Parameter cost: Defult value is -1.
     */
    init(name: String, cost: Int? = nil) {
        self.name = name
        self.cost = cost
    }
    
    /**
     Interpret cost value to adequate string.
     
     - ToDo: Search appropriate class to place this function.
     */
    func costInterpret() -> String {
        if let cost = cost {
            if (cost - 10) % 100 == 0 {
                return String(cost - 10) + "원부터"
            } else {
                return String(cost) + "원"
            }
        } else {
            return ""
        }
    }
}
