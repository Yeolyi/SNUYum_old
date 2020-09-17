//
//  OperatingHourStruct.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/// Tuple with hour and minute.
struct SimpleTime {
    let hour: Int
    let minute: Int
    
    init(_ hour: Int, _ minute: Int = 0) {
        self.hour = hour
        self.minute = minute
    }
    
    init(date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
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


/**
 Cafeteria operating hour of one day three meals; nil if cafe does not open.
 
 */
struct DailyOperatingHour {
    var bkf: String?
    var lunch: String?
    var dinner: String?
    
    /**
     Creates a cafe operating hour information.
     
     - Todo: Set default value to nil.
     */
    init(_ bkf: String?, _ lunch: String?, _ dinner: String?) {
        self.bkf = bkf
        self.lunch = lunch
        self.dinner = dinner
    }
    
    /// Get operating time info of specific meal time
    func operatingHour(at mealType: MealType) -> String? {
        switch (mealType) {
        case .breakfast:
            return bkf
        case .lunch:
            return lunch
        case .dinner:
            return dinner
        }
    }
    
    /// Convert operation start time string to hour and minute tuple
    func startTime(at mealType: MealType) -> SimpleTime? {
        if let str = operatingHour(at: mealType) {
            let splited = str.components(separatedBy: "-")
            let endTimeStr = splited[0]
            let hourNMinute = endTimeStr.components(separatedBy: ":")
            if let hour = Int(hourNMinute[0]), let minute = Int(hourNMinute[1]) {
                return SimpleTime(hour, minute)
            }
        }
        return nil
    }
    
    /// Convert operation end time string to hour and minute tuple
    func endTime(at mealType: MealType) -> SimpleTime? {
        if let str = operatingHour(at: mealType) {
            let splited = str.components(separatedBy: "-")
            let endTimeStr = splited[1]
            let hourNMinute = endTimeStr.components(separatedBy: ":")
            if let hour = Int(hourNMinute[0]), let minute = Int(hourNMinute[1]) {
                return SimpleTime(hour, minute)
            }
        }
        return nil
    }
}

/// Cafeteria operating hour of one week
struct WeeklyOperatingHour {
    var weekday: DailyOperatingHour?
    var saturday: DailyOperatingHour?
    var sunday: DailyOperatingHour?
    
    /// Return daily operating hour of input date
    func getDaily(at date: Date) -> DailyOperatingHour? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let str = dateFormatter.string(from: date)
        switch (str) {
        case "Saturday":
            return saturday
        case "Sunday":
            return sunday
        default:
            return weekday
        }
    }
}
