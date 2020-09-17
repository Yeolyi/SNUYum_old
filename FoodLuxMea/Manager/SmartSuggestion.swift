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
    static let bkfDefaultTime = SimpleTime(10)
    static let lunchDefaultTime = SimpleTime(15)
    static let dinnerDefaultTime = SimpleTime(19)
    
    
    static func get(at date: Date, cafeName: String) -> (isTomorrow: Bool, meal: MealType) {
        let currentSimpleDate = SimpleTime(date: date)
        let bkfEndTime: SimpleTime?
        let lunchEndTime: SimpleTime?
        let dinnerEndTime: SimpleTime?
        if let weeklyOperatingHour = cafeOperatingHour[cafeName] {
            bkfEndTime = weeklyOperatingHour.dayOfTheWeek(date: date)?.endTime(at: .breakfast)
            lunchEndTime = weeklyOperatingHour.dayOfTheWeek(date: date)?.endTime(at: .lunch)
            dinnerEndTime = weeklyOperatingHour.dayOfTheWeek(date: date)?.endTime(at: .dinner)
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
