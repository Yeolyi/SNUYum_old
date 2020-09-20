//
//  OperatingHourStruct.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/// Cafeteria operating hour of one day three meals; nil if cafe does not open.
struct DailyOperatingTime {
  var breakfast: String?
  var lunch: String?
  var dinner: String?
  
  /// Creates a cafe operating hour information.
  ///
  /// - Todo: Set default value to nil.
  init(_ bkf: String?, _ lunch: String?, _ dinner: String?) {
    self.breakfast = bkf
    self.lunch = lunch
    self.dinner = dinner
  }
  
  /// Get operating time info of specific meal time
  func operatingTimeStr(at mealType: MealType) -> String? {
    switch mealType {
    case .breakfast: return breakfast
    case .lunch: return lunch
    case .dinner: return dinner
    }
  }
  
  /// Convert operation start time string to hour and minute tuple
  func getStartTime(at mealType: MealType) -> SimpleTimeBorder? {
    if let str = operatingTimeStr(at: mealType) {
      let splited = str.components(separatedBy: "-")
      let endTimeStr = splited[0]
      let hourNMinute = endTimeStr.components(separatedBy: ":")
      if let hour = Int(hourNMinute[0]), let minute = Int(hourNMinute[1]) {
        return SimpleTimeBorder(hour, minute)
      }
    }
    return nil
  }
  
  /// Convert operation end time string to hour and minute tuple
  func getEndTime(at mealType: MealType) -> SimpleTimeBorder? {
    if let str = operatingTimeStr(at: mealType) {
      let splited = str.components(separatedBy: "-")
      let endTimeStr = splited[1]
      let hourNMinute = endTimeStr.components(separatedBy: ":")
      if let hour = Int(hourNMinute[0]), let minute = Int(hourNMinute[1]) {
        return SimpleTimeBorder(hour, minute)
      }
    }
    return nil
  }
}

/// Cafeteria operating hour of one week
struct WeeklyOperatingHour {
  var weekday: DailyOperatingTime?
  var saturday: DailyOperatingTime?
  var sunday: DailyOperatingTime?
  
  /// Return daily operating hour of input date
  func getDaily(at date: Date) -> DailyOperatingTime? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let str = dateFormatter.string(from: date)
    switch str {
    case "Saturday":
      return saturday
    case "Sunday":
      return sunday
    default:
      return weekday
    }
  }
}
