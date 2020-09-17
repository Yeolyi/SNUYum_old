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
    
    //As suggestion only depends on closing time, starting time is unnecessary.
    /// Some cafe's morning operating hour end time; nil if cafe does not opens.
    var bkfEndTime: SimpleTime? = nil
    /// Some cafe's afternoon operating hour end time; nil if cafe does not opens.
    var lunchEndTime: SimpleTime? = nil
    /// Some cafe's evening operating hour end time; nil if cafe does not opens.
    var dinnerEndTime: SimpleTime? = nil
    
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
        
        return (dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime) < SimpleTime(hour, minute)
    }
    
    /// Returns adequate meal type based on date parameter.
    func mealType(at date: Date) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let inputDate = SimpleTime(hour, minute)
        if inputDate < (bkfEndTime ?? SmartSuggestion.bkfDefaultTime) {
            return .breakfast
        }
        else if inputDate < (lunchEndTime ?? SmartSuggestion.lunchDefaultTime) {
            return .lunch
        }
        else if inputDate < (dinnerEndTime ?? SmartSuggestion.dinnerDefaultTime) {
            return .dinner
        }
        else {
            return .breakfast
        }
    }
    
}


/// Tuple with hour and minute.
struct SimpleTime {
    let hour: Int
    let minute: Int
    
    init(_ hour: Int, _ minute: Int = 0) {
        self.hour = hour
        self.minute = minute
    }
    
    static func <(left: SimpleTime, right: SimpleTime) -> Bool {
        if (left.hour < right.hour) {
            return true
        }
        else if (left.hour == right.hour) {
            return left.minute < right.minute
        }
        else {
            return false
        }
    }
}
