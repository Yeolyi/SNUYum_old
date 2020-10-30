//
//  SmartSuggestion.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/// Manage adequate meal type based on time.
struct DailyProposer {
    
    var isTomorrow: Bool {
        let currentSimpleDate = SimpleTime(date: date)
        var dinnerEndTime: SimpleTime?
        if cafeName != nil, let weeklyOperatingHour = cafeOperatingHour[cafeName!] {
            dinnerEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .dinner)
        }
        let isTomorrow = (dinnerEndTime ?? dinnerDefaultTime) < currentSimpleDate
        return isTomorrow
    }
    
    var meal: MealType {
        let currentSimpleDate = SimpleTime(date: date)
        var bkfEndTime: SimpleTime?
        var lunchEndTime: SimpleTime?
        var dinnerEndTime: SimpleTime?
        if cafeName != nil, let weeklyOperatingHour = cafeOperatingHour[cafeName!] {
            bkfEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .breakfast)
            lunchEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .lunch)
            dinnerEndTime = weeklyOperatingHour.daily(at: date)?.endTime(at: .dinner)
        }
        let suggestedMeal: MealType
        switch currentSimpleDate {
        case ..<(bkfEndTime ?? bkfDefaultTime):
            suggestedMeal = .breakfast
        case (bkfEndTime ?? bkfDefaultTime)..<(lunchEndTime ?? lunchDefaultTime):
            suggestedMeal = .lunch
        case (lunchEndTime ?? lunchDefaultTime)..<(dinnerEndTime ?? dinnerDefaultTime):
            suggestedMeal = .dinner
        default:
            suggestedMeal = .breakfast
        }
        
        return suggestedMeal
    }
    
    init(at date: Date, cafeName: String?) {
        self.date = date
        self.cafeName = cafeName
    }
    
    // Default SimpleTimeBorder structs in case operating hour does not exists.
    private let bkfDefaultTime = SimpleTime(hour: 10)
    private let lunchDefaultTime = SimpleTime(hour: 15)
    private let dinnerDefaultTime = SimpleTime(hour: 19)
    
    private let date: Date
    private let cafeName: String?
    
    static func getDefault(meal: MealType) -> SimpleTime {
        switch meal {
        case .breakfast:
            return SimpleTime(hour: 10)
        case .lunch:
            return SimpleTime(hour: 15)
        case .dinner:
            return SimpleTime(hour: 19)
        }
    }
}
