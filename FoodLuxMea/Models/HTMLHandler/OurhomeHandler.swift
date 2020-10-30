//
//  Ourhome Manager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/05.
//

import SwiftSoup
import SwiftUI

/// Get data about our home cafeteria
struct OurhomeHandler {
    
    @AutoSave("OurhomeMenus", defaultValue: [URL: [Int: Cafe]]())
    static private var cafeData: [URL: [Int: Cafe]]
    
    static func clear() {
        cafeData = [:]
    }
    
    static func cafe(date: Date) throws -> Cafe? {
        func dateToDayOfWeek(_ date: Date) -> Int {
            let myCalendar = Calendar(identifier: .gregorian)
            let weekDay = myCalendar.component(.weekday, from: date)
            return weekDay - 1
        }
        if let data = cafeData[makeURL(from: date)]?[dateToDayOfWeek(date)] {
            return data
        } else {
            print("Downloading ourhome data...")
            let data = try loadCafe(date: date)
            return data[dateToDayOfWeek(date)]
        }
    }
    
    static private func loadCafe(date: Date) throws -> [Int: Cafe] {
        let data = menuToCafe(try menuList(date: date))
        cafeData[makeURL(from: date)] = data
        return data
    }
    
    static private func menuList(date: Date) throws -> [Int: [Menu?]] {
        /// Cafe order in ourhome HTML.
        let cafeNameOrder = ["가마", "인터쉐프", "가마", "인터쉐프", "해피존", "가마", "인터쉐프", "해피존"]
        /// Temp menu list storage
        var cafeDayofWeek: [Int: [Menu?]] = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: []]
        /// Unnessessary data number
        let wasteDataNum = [3, 1, 2, 1, 1, 2, 1, 1]
        let uRLContents = try String(contentsOf: makeURL(from: date))
        let parsed = try SwiftSoup.parse(uRLContents)
        // Divide rows - each row has 8 columns.
        let rawCafeList = try parsed.select("div#container").select("tbody").select("tr").array()
        for rowNum in 0..<8 {
            let mealArray = try rawCafeList[rowNum].select("td").array()
            let infoStartIndex = wasteDataNum[rowNum]
            for columnNum in infoStartIndex..<infoStartIndex + 7 {
                let menuName = try mealArray[columnNum].select("li").text()
                guard menuName != "" else {
                    let dayOfWeek = columnNum - infoStartIndex
                    cafeDayofWeek[dayOfWeek]!.append(nil)
                    continue
                }
                let cost = getCost(menuName: try mealArray[columnNum].select("li").attr("class"))
                let dayOfWeek = columnNum - infoStartIndex
                cafeDayofWeek[dayOfWeek]!.append(Menu(name: "\(menuName) - \(cafeNameOrder[rowNum])", cost: cost))
            }
        }
        return cafeDayofWeek
    }
    
    static private func menuToCafe(_ weeklyMenuList: [Int: [Menu?]]) -> [Int: Cafe] {
        func divideMealType(of meal: MealType, dayOfTheWeek: Int) -> [Menu] {
            let mealIndex: [Int]
            switch meal {
            case .breakfast:
                mealIndex = [0, 1]
            case .lunch:
                mealIndex = [2, 3, 4]
            case .dinner:
                mealIndex = [5, 6, 7]
            }
            var menuList: [Menu] = []
            for i in mealIndex {
                if let menu = weeklyMenuList[dayOfTheWeek]?[i] {
                    menuList.append(menu)
                }
            }
            return menuList
        }
        var cafeList = [Int: Cafe]()
        for day in 0..<7 {
            let bkfMenuList: [Menu] = divideMealType(of: .breakfast, dayOfTheWeek: day)
            let lunchMenuList: [Menu] = divideMealType(of: .lunch, dayOfTheWeek: day)
            let dinnerMenuList: [Menu] = divideMealType(of: .dinner, dayOfTheWeek: day)
            cafeList[day] =
                Cafe(name: "아워홈", phoneNum: "", bkfMenuList: bkfMenuList, lunchMenuList: lunchMenuList, dinnerMenuList: dinnerMenuList)
        }
        return cafeList
    }
    
    static private func makeURL(from date: Date) -> URL {
        let baseNum = 1597503600
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let baseDate = formatter.date(from: "2020/08/16 00:00")!
        let components = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: Date())
        return URL(
            string:
                "https://dorm.snu.ac.kr/dk_board/facility/food.php?start_date2=" +
                "\(baseNum + components.weekOfYear! * 60 * 60 * 24 * 7)"
        )!
    }
    
    /// Convert HTML class attrubution to cost value
    static private func getCost(menuName: String) -> Int? {
        switch menuName {
        case "menu_a": return 2000
        case "menu_b": return 2500
        case "menu_c": return 3000
        case "menu_d": return 3500
        case "menu_e": return 4000
        case "menu_f": return 5000
        default: return nil
        }
    }
}
