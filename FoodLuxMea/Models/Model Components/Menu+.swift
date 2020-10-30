//
//  Menu+.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/20.
//

import Foundation

/// Indicates one of these three meals; breakfast, lunch and dinner.
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
struct Menu: Hashable, Codable, Identifiable {
    
    var id = UUID()
    let name: String
    let cost: Int?
    
    var costStr: String {
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
    
    init(name: String, cost: Int? = nil) {
        self.name = name
        self.cost = cost
    }
}
