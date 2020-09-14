//
//  CafeStruct.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/// Indicates one of three meals; breakfast, lunch and dinner
enum MealType: String, Codable {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
}

/// Data of single menu
struct Menu: Hashable, Codable, Identifiable {
    var id = UUID()
    let name: String
    let cost: Int
}

/// Struct representing single cafeteria
struct Cafe: Hashable, Codable, Identifiable {
    var id = UUID()
    let name: String
    let phoneNum: String
    let bkfMenuList: [Menu]
    let lunchMenuList: [Menu]
    let dinnerMenuList: [Menu]
    
    /**
     True if there is no menu in selected meal type
     
     - Parameters:
        - mealType: Select which meal type to search
        - keywords: Exceptional strings which means menu is empty.
     */
    func isEmpty(mealType: MealType, keywords: [String]) -> Bool {
        let targetMenuList: [Menu]
        switch (mealType) {
        case .breakfast:
            targetMenuList = bkfMenuList
        case .lunch:
            targetMenuList = lunchMenuList
        case .dinner:
            targetMenuList = dinnerMenuList
        }
        if (targetMenuList.count == 0 ) { return true }
        else if (targetMenuList.count > 1) { return false}
        else {
            for keyword in keywords {
                if targetMenuList.contains(where: { $0.name == keyword }) {
                    return true
                }
            }
            return false
        }
    }
    
    /**
     Get menu list of selected meal type
     
     - Parameter mealType: Select which meal type to get
    */
    func getMenuList(mealType: MealType) -> [Menu] {
        switch mealType {
        case .breakfast:
            return bkfMenuList
        case .lunch:
            return lunchMenuList
        case .dinner:
            return dinnerMenuList
        }
    }
    
    /**
     True if list contains searching text
     
     - Parameter mealType: Select which meal list to search
     - Parameter str: Searching text
    */
    func searchText(_ str: String, mealType: MealType) -> Bool {
        if (name.contains(str)) {
            return true
        }
        let menuList = getMenuList(mealType: mealType)
        for menu in menuList{
            if (menu.name.contains(str)) {
                return true
            }
        }
        return false
    }
}

/// Cafeteria operating hour of one day three meals; nil if cafe does not open
struct DailyOperatingHour {
    var bkf: String?
    var lunch: String?
    var dinner: String?
    
    init(_ bkf: String?, _ lunch: String?, _ dinner: String?) {
        self.bkf = bkf
        self.lunch = lunch
        self.dinner = dinner
    }
    
    /// Get operating time info of specific meal time
    func meal(_ mealType: MealType) -> String? {
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
    func mealTypeToStartTime(_ mealType: MealType) -> (hour: Int, minute: Int)? {
        if let str = meal(mealType) {
            let splited = str.components(separatedBy: "-")
            let endTimeStr = splited[0]
            let hourNMinute = endTimeStr.components(separatedBy: ":")
            if let hour = Int(hourNMinute[0]), let minute = Int(hourNMinute[1]) {
                return (hour, minute)
            }
        }
        return nil
    }
    
    /// Convert operation end time string to hour and minute tuple
    func mealTypeToEndTime(_ mealType: MealType) -> (hour: Int, minute: Int)? {
        if let str = meal(mealType) {
            let splited = str.components(separatedBy: "-")
            let endTimeStr = splited[1]
            let hourNMinute = endTimeStr.components(separatedBy: ":")
            if let hour = Int(hourNMinute[0]), let minute = Int(hourNMinute[1]) {
                return (hour, minute)
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
    func dayOfTheWeek(date: Date) -> DailyOperatingHour? {
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

/// Return day of the week string from input date
func dayOfTheWeek(of date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let str = dateFormatter.string(from: date)
    switch (str) {
    case "Saturday":
        return "토요일"
    case "Sunday":
        return "일요일"
    default:
        return "평일"
    }
}
