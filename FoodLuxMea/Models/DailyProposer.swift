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
class DailyProposer {
    
    // Default SimpleTimeBorder structs in case operating hour does not exists.
    static let bkfDefaultTime = SimpleTime(hour: 10)
    static let lunchDefaultTime = SimpleTime(hour: 15)
    static let dinnerDefaultTime = SimpleTime(hour: 19)
    
    static func getDefault(meal: MealType) -> SimpleTime {
        switch meal {
        case .breakfast:
            return bkfDefaultTime
        case .lunch:
            return lunchDefaultTime
        case .dinner:
            return dinnerDefaultTime
        }
    }
    //??왜 이따구로 짬??
    static func menu(at date: Date, cafeName: String) -> (isTomorrow: Bool, meal: MealType) {
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
        let isTomorrow = (dinnerEndTime ?? DailyProposer.dinnerDefaultTime) < currentSimpleDate
        let suggestedMeal: MealType
        if currentSimpleDate < (bkfEndTime ?? DailyProposer.bkfDefaultTime) {
            suggestedMeal = .breakfast
        } else if currentSimpleDate < (lunchEndTime ?? DailyProposer.lunchDefaultTime) {
            suggestedMeal = .lunch
        } else if currentSimpleDate < (dinnerEndTime ?? DailyProposer.dinnerDefaultTime) {
            suggestedMeal = .dinner
        } else {
            suggestedMeal = .breakfast
        }
        return (isTomorrow, suggestedMeal)
    }
}
