//
//  SmartSuggestion.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

class SmartSuggestion {
    
    static let bkfDefaultTime = (10, 0)
    static let lunchDefaultTime = (15, 0)
    static let dinnerDefaultTime = (19,0)
    
    var bkfEndTime: (Int, Int)? = nil
    var lunchEndTime: (Int, Int)? = nil
    var dinnerEndTime: (Int, Int)? = nil
    
    func update(dailyOperatingHour: DailyOperatingHour?) {
        if let dailyOperatingHourUnwrapped = dailyOperatingHour {
            bkfEndTime = dailyOperatingHourUnwrapped.mealTypeToEndTime(.breakfast)
            lunchEndTime = dailyOperatingHourUnwrapped.mealTypeToEndTime(.lunch)
            dinnerEndTime = dailyOperatingHourUnwrapped.mealTypeToEndTime(.dinner)
        }
        else {
            bkfEndTime = nil
            lunchEndTime = nil
            dinnerEndTime = nil
        }
    }
    
    func isTomorrow(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return isRhsBigger(lhs: dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime, rhs: (hour, minute))
    }
    
    func mealType(at date: Date) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let inputDate = (hour, minute)
        if (isRhsBigger(lhs: inputDate, rhs: bkfEndTime ?? SmartSuggestion.bkfDefaultTime)) {
            return .breakfast
        }
        else if (isRhsBigger(lhs: inputDate, rhs: lunchEndTime ?? SmartSuggestion.lunchDefaultTime)) {
            return .lunch
        }
        else if (isRhsBigger(lhs: inputDate, rhs: dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime)) {
            return .dinner
        }
        else {
            return .breakfast
        }
    }
    
}

func isRhsBigger(lhs: (hour: Int, minute: Int), rhs: (hour: Int, minute: Int)) -> Bool{
    if (lhs.hour < rhs.hour) {
        return true
    }
    else if (lhs.hour == rhs.hour) {
        return lhs.minute < rhs.minute
    }
    else {
        return false
    }
}
