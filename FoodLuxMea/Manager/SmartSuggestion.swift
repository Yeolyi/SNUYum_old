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
class SmartSuggestion {
    
    // Hour and minute tuples for when operating hour does not exists.
    static let bkfDefaultTime = SimpleTimeBorder(10)
    static let lunchDefaultTime = SimpleTimeBorder(15)
    static let dinnerDefaultTime = SimpleTimeBorder(19)
    
    static func get(at date: Date, cafeName: String) -> (isTomorrow: Bool, meal: MealType) {
        let currentSimpleDate = SimpleTimeBorder(date: date)
        let bkfEndTime: SimpleTimeBorder?
        let lunchEndTime: SimpleTimeBorder?
        let dinnerEndTime: SimpleTimeBorder?
        if let weeklyOperatingHour = cafeOperatingHour[cafeName] {
            bkfEndTime = weeklyOperatingHour.getDaily(at: date)?.getEndTime(at: .breakfast)
            lunchEndTime = weeklyOperatingHour.getDaily(at: date)?.getEndTime(at: .lunch)
            dinnerEndTime = weeklyOperatingHour.getDaily(at: date)?.getEndTime(at: .dinner)
        }
        else {
            bkfEndTime = nil
            lunchEndTime = nil
            dinnerEndTime = nil
        }
        let isTomorrow = (dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime) < currentSimpleDate
        let suggestedMeal: MealType
        if currentSimpleDate < (bkfEndTime ?? SmartSuggestion.bkfDefaultTime) {
            suggestedMeal = .breakfast
        }
        else if currentSimpleDate < (lunchEndTime ?? SmartSuggestion.lunchDefaultTime) {
            suggestedMeal = .lunch
        }
        else if currentSimpleDate < (dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime) {
            suggestedMeal = .dinner
        }
        else {
            suggestedMeal = .breakfast
        }
        return (isTomorrow, suggestedMeal)
    }
}
