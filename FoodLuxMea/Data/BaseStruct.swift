//
//  CafeStruct.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

enum MealType: String, Codable {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
}

struct Menu: Hashable, Codable, Identifiable {
    var id = UUID()
    let name: String
    let cost: Int
}

struct Cafe: Hashable, Codable, Identifiable {
    var id = UUID()
    let name: String
    let phoneNum: String
    let bkfMenuList: [Menu]
    let lunchMenuList: [Menu]
    let dinnerMenuList: [Menu]
    
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
    
    func getMenuList(MealType: MealType) -> [Menu] {
        switch MealType {
        case .breakfast:
            return bkfMenuList
        case .lunch:
            return lunchMenuList
        case .dinner:
            return dinnerMenuList
        }
    }
    
    func searchText(_ str: String) -> Bool {
        if (name.contains(str)) {
            return true
        }
        if (phoneNum.contains(str)) {
            return true
        }
        for menu in bkfMenuList + lunchMenuList + dinnerMenuList{
            if (menu.name.contains(str) || String(menu.cost).contains(str)) {
                return true
            }
        }
        return false
    }
}

struct DailyOperatingHour {
    var bkf: String?
    var lunch: String?
    var dinner: String?
    
    init(_ bkf: String?, _ lunch: String?, _ dinner: String?) {
        self.bkf = bkf
        self.lunch = lunch
        self.dinner = dinner
    }
    
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

enum DayOfTheWeek {
    case weekend, saturday, sunday
}

struct WeeklyOperatingHour {
    var weekday: DailyOperatingHour?
    var saturday: DailyOperatingHour?
    var sunday: DailyOperatingHour?
    
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
