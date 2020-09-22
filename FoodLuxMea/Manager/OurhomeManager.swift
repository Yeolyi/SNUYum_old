//
//  Ourhome Manager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/05.
//

import SwiftSoup
import SwiftUI

/// Get data about our home cafeteria
///
/// - Note: Ourhome data uses one cafe struct. As this class downloads one week amount of cafe data,
/// this has independent data storage and userdefaults.
class OurhomeManager {
    
    /// Independent cafeData storage.
    ///
    /// In [Int: Cafe], Int value is converted from day of the week; sunday is 0, saturday is 6.
    var cafeData = [URL: [Int: Cafe]]()
    
    /// Get saved data.
    init() {
        if let loadedData = UserDefaults(
            suiteName: "group.com.wannasleep.FoodLuxMea")?.value(forKey: "ourhomeData") as? Data {
            do {
                cafeData = try PropertyListDecoder().decode([URL: [Int: Cafe]].self, from: loadedData)
                print("ourhomeData가 로드되었습니다")
            } catch {
                assertionFailure("Ourhome initialization failed.")
                cafeData = [:]
            }
        }
    }
    
    /// Save downloaded data to optimize app.
    func save() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if let encodedData = try? PropertyListEncoder().encode(cafeData) {
                userDefault.set(encodedData, forKey: "ourhomeData")
                print("OurhomeData saved.")
            } else {
                assertionFailure("OurhomeData encoding failed.")
            }
        } else {
            assertionFailure("Userdefaults loading failed.")
        }
    }
    
    func getCafe(date: Date) -> Cafe? {
        
        /// Get cafeData index using date parameter.
        func savedDataIndex(_ date: Date) -> Int {
            let myCalendar = Calendar(identifier: .gregorian)
            let weekDay = myCalendar.component(.weekday, from: date)
            return weekDay - 1
        }
        
        // Data already saved.
        if let data = cafeData[makeURL(from: date)] {
            return data[savedDataIndex(date)]
        }
        // Data should be downloaded.
        else {
            if let data = loadCafe(date: date) {
                cafeData[makeURL(from: date)] = data
                save()
                return data[savedDataIndex(date)]
            } else {
                return nil
            }
        }
        
    }
    
    func loadCafe(date: Date) -> [Int: Cafe]? {
        
        /// Unnessessary data num in array.
        let wasteDataNum = [3, 1, 2, 1, 1, 2, 1, 1]
        /// Cafe order in ourhome HTML.
        let cafeNameOrder = ["가마", "인터쉐프", "가마", "인터쉐프", "해피존", "가마", "인터쉐프", "해피존"]
        // Meal type index in ourhome HTML.
        let bkfIndex = [0, 1]
        let lunchIndex = [2, 3, 4]
        let dinnerIndex = [5, 6, 7]
        
        /// Return value
        var cafeList = [Int: Cafe]()
        /// Temp menu list storage
        var cafeDayofWeek = [Int: [Menu?]]()
        
        for i in 0..<8 {
            cafeDayofWeek[i] = []
        }
        
        do {
            let uRLContents = makeURL(from: date)
            let parsed = try SNUCOManager.parse(uRLContents)
            
            // Divide rows - each row has 8 columns.
            let rawCafeList = try parsed.select("div#container").select("tbody").select("tr").array()
            // Iterate rows.
            for rowNum in 0..<8 {
                // Single row information.
                let mealArray = try rawCafeList[rowNum].select("td").array()
                // Only get useful information using proper range.
                for columnNum in wasteDataNum[rowNum]..<wasteDataNum[rowNum] + 7 {
                    let menuName = try mealArray[columnNum].select("li").text()
                    let dayOfWeek = columnNum - wasteDataNum[rowNum]
                    let cost = getCost(menuName: try mealArray[columnNum].select("li").attr("class"))
                    let menu = menuName == "" ? nil : Menu(name: "\(cafeNameOrder[rowNum]) - \(menuName)", cost: cost)
                    cafeDayofWeek[dayOfWeek]!.append(menu)
                }
            }
            
            func divideMealType(index: [Int], dayOfTheWeek: Int) -> [Menu] {
                var menuList = [Menu]()
                for i in index {
                    if let tempMenu = cafeDayofWeek[dayOfTheWeek]![i] { menuList.append(tempMenu) }
                }
                return menuList
            }
            
            for day in 0..<7 {
                let tempBkfMenuList: [Menu] = divideMealType(index: bkfIndex, dayOfTheWeek: day)
                let tempLunchMenuList: [Menu] = divideMealType(index: lunchIndex, dayOfTheWeek: day)
                let tempDinnerMenuList: [Menu] = divideMealType(index: dinnerIndex, dayOfTheWeek: day)
                cafeList[day] =
                    Cafe(
                        name: "아워홈",
                        phoneNum: "",
                        bkfMenuList: tempBkfMenuList,
                        lunchMenuList: tempLunchMenuList,
                        dinnerMenuList: tempDinnerMenuList
                    )
            }
            return cafeList
        } catch {
            return nil
        }
    }
    
    func makeURL(from date: Date) -> URL {
        let baseNum = 1597503600
        let baseDate = trimDate(using: "2020/08/16 00:00")
        let components = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date)
        return URL(
            string:
                "https://dorm.snu.ac.kr/dk_board/facility/food.php?start_date2=" +
                "\(baseNum + components.weekOfYear! * 60 * 60 * 24 * 7)"
        )!
    }
    
    /// Convert HTML class attrubution to cost value
    func getCost(menuName: String) -> Int {
        switch menuName {
        case "menu_a": return 2000
        case "menu_b": return 2500
        case "menu_c": return 3000
        case "menu_d": return 3500
        case "menu_e": return 4000
        case "menu_f": return 5000
        default: return -1
        }
    }
    
    /// Convert yyyy/MM/dd HH:mm style string to Date
    func trimDate(using string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = formatter.date(from: string) ?? Date()
        guard let trimmedDate = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month, .day], from: date)
        ) else {
            assertionFailure("")
            return Date()
        }
        return trimmedDate
    }
    
}
