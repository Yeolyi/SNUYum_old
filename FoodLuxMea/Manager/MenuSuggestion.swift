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
    static let bkfDefaultTime = SimpleTimeBorder(10)
    static let lunchDefaultTime = SimpleTimeBorder(15)
    static let dinnerDefaultTime = SimpleTimeBorder(19)
    
    static func properMenu(at date: Date, cafeName: String) -> (isTomorrow: Bool, meal: MealType) {
        let currentSimpleDate = SimpleTimeBorder(date: date)
        let bkfEndTime: SimpleTimeBorder?
        let lunchEndTime: SimpleTimeBorder?
        let dinnerEndTime: SimpleTimeBorder?
        if let weeklyOperatingHour = cafeOperatingHour[cafeName] {
            bkfEndTime = weeklyOperatingHour.getDaily(at: date)?.getEndTime(at: .breakfast)
            lunchEndTime = weeklyOperatingHour.getDaily(at: date)?.getEndTime(at: .lunch)
            dinnerEndTime = weeklyOperatingHour.getDaily(at: date)?.getEndTime(at: .dinner)
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
