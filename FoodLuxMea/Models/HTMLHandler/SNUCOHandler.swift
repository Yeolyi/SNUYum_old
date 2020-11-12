//
//  HTMLManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import SwiftSoup

/// Make cafe array from html source
struct SNUCOHandler {
    
    @AutoSave("SNUCOMenus", defaultValue: [URL: [Cafe]]())
    static private var cafeData: [URL: [Cafe]]
    
    static func cafe(_ cafeName: String, date: Date) throws -> Cafe? {
        if let cafe = cafeData[makeURL(from: date)]?.first(where: {$0.name == cafeName}) {
            return cafe
        } else if let cafe = try download(at: date).first(where: {$0.name == cafeName}) {
            return cafe
        } else {
            return nil
        }
    }
    
    static func cafe(date: Date) throws -> [Cafe] {
        if let cafe = cafeData[makeURL(from: date)] {
            return cafe
        } else {
            return try download(at: date)
        }
    }
    
    static func clear() {
        cafeData = [:]
    }
    
    /// URL to SNUCO homepage showing specific date's cafe menu
    static private func makeURL(from date: Date) -> URL {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: date)
        let targetURLString = """
        https://snuco.snu.ac.kr/ko/\
        foodmenu?field_menu_date_value_1%5Bvalue%5D%5Bdate%5D=&field_menu_date_value%5Bvalue%5D%5Bdate%5D=\
        \(dateComponents.month!)%2F\(dateComponents.day!)%2F\(dateComponents.year!)
        """
        if let targetURL = URL(string: targetURLString) {
            return targetURL
        } else {
            assertionFailure("String to URL failed - \(targetURLString)")
            return URL(string: "https://snuco.snu.ac.kr/ko/foodmenu")!
        }
    }
    
    /// Get whole snuco cafe datas at specific date
    static private func download(at date: Date) throws -> [Cafe] {
        let uRLContents = try String(contentsOf: makeURL(from: date))
        let parsed = try SwiftSoup.parse(uRLContents)
        let rawCafeList: [Element] = try parsed.select("div.view-content").select("tbody").select("tr").array()
        let result = try rawCafeList.compactMap(splitElement)
        cafeData[makeURL(from: date)] = result
        return result
    }
    
    /// Get single cafe properties from single element
    static private func splitElement(_ element: Element) throws -> Cafe {
        let rawCafe = try element.select("td").array()
        let nameNum = try separateNameNum(try rawCafe[0].text())
        return Cafe(
            name: nameNum.name,
            phoneNum: nameNum.callNum,
            bkfMenuList: try splitMenuList(rawCafe, meal: .breakfast),
            lunchMenuList: try splitMenuList(rawCafe, meal: .lunch),
            dinnerMenuList: try splitMenuList(rawCafe, meal: .dinner)
        )
    }
    
    /// Separate cafe name and phone num from "학생회관식당(1234-5678)" format data
    static private func separateNameNum(_ str: String) throws -> (name: String, callNum: String) {
        let tempArr = str.components(separatedBy: ["("])
        guard tempArr.count == 2 else {
            assertionFailure("Data missing")
            return ("", "")
        }
        let name = String(tempArr[0])
        let callNum = String(tempArr[1].dropLast())
        return (name, callNum)
    }
    
    static private func isMenuException(_ menuNCost: String) -> (isException: Bool, save: Bool) {
        if menuNCost.isEmpty {
            return (true, false)
        } else if menuNCost.contains("운영") {
            return (true, false)
        } else if menuNCost.contains("혼잡") {
            return (true, true)
        } else if menuNCost[menuNCost.startIndex] == "<" {
            return (true, true)
        } else if menuNCost.contains("코로나") {
            return (true, true)
        } else {
            return (false, false)
        }
    }
    
    static private func splitMenu(result: [Menu], next: String) -> [Menu] {
        guard !next.isEmpty else {
            return result
        }
        switch isMenuException(next) {
        case (false, _):
            break
        case (true, false):
            return result
        case (true, true):
            return result + [.init(name: next)]
        }
        // Find index dividing menu name and cost
        for index in next.indices {
            guard index != next.index(before: next.endIndex) else {
                break
            }
            let currentStr = String(next[index])
            let nextStr = String(next[next.index(after: index)])
            if Int(currentStr) != nil && (nextStr == "," || Int(nextStr) != nil ) {
                let name = String(next[..<index]).whiteSpaceTrimmed
                var cost = String(next[index...]).decimal
                if cost != nil && String(next[index...]).contains("~") {
                    cost! += 10
                }
                return result + [.init(name: name, cost: cost)]
            }
        }
        return result + [.init(name: next)]
    }
    
    static private func splitMenuList(_ rawCafe: [Element], meal: MealType) throws -> [Menu] {
        let mealOrder: [MealType: Int] = [.breakfast: 1, .lunch: 2, .dinner: 3]
        let rawMenus = try rawCafe[mealOrder[meal]!].select("p").array()
        return try rawMenus.reduce([], { (result: [Menu], next: Element) -> [Menu] in
            var temp = try next.html()
            temp = temp.replacingOccurrences(of: "<br>", with: "꿇")
            temp = try SwiftSoup.parse(temp).text()
            let menuList = temp.split(separator: "꿇").map(String.init).map {$0.whiteSpaceTrimmed}
            return result + menuList.reduce([], splitMenu)
        })
    }
}

extension String {
    /// Delete edge white space in string
    var whiteSpaceTrimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    /// Decimal only in string
    var decimal: Int? {
        Int(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
