//
//  SmartSuggestion.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/**
 Manage adequate meal type based on time.
 */
class MenuSuggestion {
    
    // Default SimpleTimeBorder structs in case operating hour does not exists.
    static let bkfDefaultTime = SimpleTime(hour: 10)
    static let lunchDefaultTime = SimpleTime(hour: 15)
    static let dinnerDefaultTime = SimpleTime(hour: 19)
    
    static func properMenu(at date: Date, cafeName: String) -> (isTomorrow: Bool, meal: MealType) {
        let currentSimpleDate = SimpleTime(date: date)
        let bkfEndTime: SimpleTime?
        let lunchEndTime: SimpleTime?
        let dinnerEndTime: SimpleTime?
        if let weeklyOperatingHour = cafeOperatingHour[cafeName] {
            bkfEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .breakfast)
            lunchEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .lunch)
            dinnerEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .dinner)
        } else {
            bkfEndTime = nil
            lunchEndTime = nil
            dinnerEndTime = nil
        }
        let isTomorrow = (dinnerEndTime ?? MenuSuggestion.dinnerDefaultTime) < currentSimpleDate
        let suggestedMeal: MealType
        if currentSimpleDate < (bkfEndTime ?? MenuSuggestion.bkfDefaultTime) {
            suggestedMeal = .breakfast
        } else if currentSimpleDate < (lunchEndTime ?? MenuSuggestion.lunchDefaultTime) {
            suggestedMeal = .lunch
        } else if currentSimpleDate < (dinnerEndTime ?? MenuSuggestion.dinnerDefaultTime) {
            suggestedMeal = .dinner
        } else {
            suggestedMeal = .breakfast
        }
        return (isTomorrow, suggestedMeal)
    }
}
