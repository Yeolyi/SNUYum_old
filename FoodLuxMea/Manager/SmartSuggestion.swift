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
    static let bkfDefaultTime = (10, 0)
    static let lunchDefaultTime = (15, 0)
    static let dinnerDefaultTime = (19,0)
    
    //As suggestion shift depends on closing time, starting time is unnecessary.
    /// Some cafe's morning operating hour end time; nil if cafe does not opens.
    var bkfEndTime: (Int, Int)? = nil
    /// Some cafe's afternoon operating hour end time; nil if cafe does not opens.
    var lunchEndTime: (Int, Int)? = nil
    /// Some cafe's evening operating hour end time; nil if cafe does not opens.
    var dinnerEndTime: (Int, Int)? = nil
    
    /// Update class using some cafe's 'DailyOperatingHour' value.
    func update(dailyOperatingHour: DailyOperatingHour?) {
        if let dailyOperatingHourUnwrapped = dailyOperatingHour {
            bkfEndTime = dailyOperatingHourUnwrapped.endTime(at: .breakfast)
            lunchEndTime = dailyOperatingHourUnwrapped.endTime(at: .lunch)
            dinnerEndTime = dailyOperatingHourUnwrapped.endTime(at: .dinner)
        }
        else {
            bkfEndTime = nil
            lunchEndTime = nil
            dinnerEndTime = nil
        }
    }
    
    /**
     Returns true if time is too late.
     */
    func isTomorrow(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return isRhsBigger(lhs: dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime, rhs: (hour, minute))
    }
    
    /// Returns adequate meal type based on date parameter.
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

/// Compare two (hour, minute) tuples.
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
