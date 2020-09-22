//
//  HTMLManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import SwiftSoup

enum TestError: Error {
    case error
}

/// Get data from snuco website and process it into Cafe array.
struct SNUCOManager {
    
    struct TempCafeData {
        let name: String
        let callNum: String
        let rawBreakfasts: [Element]
        let rawLunches: [Element]
        let rawDinners: [Element]
    }
    
    /// Get Cafe array from specific date
    static func download(at date: Date) -> [Cafe] {
        /// Returning cafe array.
        var cafeData: [Cafe] = []
        /// URL to access.
        let targetURL = makeURL(from: date)
        /// Parsed HTML.
        do {
            let parsedDocument = try parse(targetURL)
            // Trying processing.
            /// Array [rawCafe1, rawCafe2,,,]
            let rawCafeList: [Element] =
                try parsedDocument.select("div.view-content").select("tbody").select("tr").array()
            // Process each cafes.
            for rawCafe in rawCafeList {
                /// Splited raw cafe data - [name, callNum, rawBreakfasts, rawLunches, rawDinners]
                let tempCafe = try splitCafeData(rawCafe)
                // rawMenuList to MenuList
                let breakfastMenus = try splitMenuList(tempCafe.rawBreakfasts)
                let lunchMenus = try splitMenuList(tempCafe.rawLunches)
                let dinnerMenus = try splitMenuList(tempCafe.rawDinners)
                // Add new Cafe to return array.
                cafeData.append(
                    .init(
                        name: tempCafe.name,
                        phoneNum: tempCafe.callNum,
                        bkfMenuList: breakfastMenus,
                        lunchMenuList: lunchMenus,
                        dinnerMenuList: dinnerMenus
                    )
                )
            }
            return cafeData
        } catch {
            assertionFailure("Html 소스 분리에 실패하였습니다.")
            return []
        }
    }
    
    /// Simply divide whole URL Element to cafe struct elements
    static private func splitCafeData(_ rawCafe: Element) throws -> TempCafeData {
        /// Array of Cafe components - [Name&PhoneNum, bkfMenuList, lunchMenuList, dinnerMenuList]
        ///
        /// First select
        let rawCafeArray = try rawCafe.select("td").array()
        guard rawCafeArray.count == 4 else {
            assertionFailure("Array count is not 4.")
            throw TestError.error
        }
        /// Cafe name and phoneNum constant with form of "name(phoneNum)"
        let nameNum = try rawCafeArray[0].text()
        // Divide two data.
        let (cafeName, cafeCallNum) = separateNameNum(nameNum)
        // Make cafe menu array
        // Second select
        let rawBreakfasts = try rawCafeArray[1].select("p").array()
        let rawLunches = try rawCafeArray[2].select("p").array()
        let rawDinners = try rawCafeArray[3].select("p").array()
        
        return TempCafeData(
            name: cafeName,
            callNum: cafeCallNum,
            rawBreakfasts: rawBreakfasts,
            rawLunches: rawLunches,
            rawDinners: rawDinners
        )
    }
    
    static private func separateNameNum(_ str: String) -> (name: String, callNum: String) {
        let tempArr = str.components(separatedBy: ["("])
        guard tempArr.count == 2 else {
            assertionFailure("Array count is not 2.")
            return ("", "")
        }
        let name = String(tempArr[0])
        let callNum = String(tempArr[1].dropLast())
        return (name, callNum)
    }
    
    /// Get cost and menu name from elements
    ///
    /// - Note: Has great importance in SNUCO data processing.
    static private func splitMenuList(_ rawMenus: [Element]) throws -> [Menu] {
        
        /// Delete edge white space in string.
        func whiteSpaceTrim(_ str: String) -> String {
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        /// Delete all characters in string except decimal.
        func decimalTrimInverted(_ str: String) -> Int? {
            return Int(str.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        }
        
        /// Returned menu array.
        var returnValue: [Menu] = []
        // Menu list is not empty.
        for rawMenu in rawMenus {
            
            // Divide each menus.
            var temp = try rawMenu.html()
            temp = temp.replacingOccurrences(of: "<br>", with: "꿇")
            temp = try SwiftSoup.parse(temp).text()
            let menuList = temp.split(separator: "꿇").map(String.init)
            
            // Divide menu name and menu cost.
            characterIterate: for menuNCost in menuList {
                let trimmedMenuNCost = whiteSpaceTrim(menuNCost)
                
                // Exceptions.
                if trimmedMenuNCost.isEmpty {
                    continue
                } else if trimmedMenuNCost[trimmedMenuNCost.startIndex] == "※" {
                    continue
                } else if trimmedMenuNCost[trimmedMenuNCost.startIndex] == "<" {
                    returnValue.append(.init(name: trimmedMenuNCost))
                    continue
                } else if trimmedMenuNCost.contains("코로나") {
                    returnValue.append(.init(name: trimmedMenuNCost))
                    continue
                }
                
                // Find cost string.
                for index in trimmedMenuNCost.indices
                where Int(String(trimmedMenuNCost[index])) != nil &&
                    ( String(trimmedMenuNCost[trimmedMenuNCost.index(after: index)]) == "," ||
                        Int(String(trimmedMenuNCost[trimmedMenuNCost.index(after: index)])) != nil ) {
                    // Found.
                    let menu = whiteSpaceTrim(String(trimmedMenuNCost[..<index]))
                    var cost = decimalTrimInverted(String(trimmedMenuNCost[index...]))
                    if cost != nil && String(trimmedMenuNCost[index...]).contains("~") {
                        cost! += 10
                    }
                    returnValue.append(.init(name: menu, cost: cost))
                    continue characterIterate
                }
                // Not found. Set all string to menu name.
                returnValue.append(.init(name: trimmedMenuNCost, cost: nil))
            }
            
        }
        return returnValue
    }
    
    /// Make URL which has access to input date's data
    ///
    /// - Note: Public because DataManager uses URL to distinguish data.
    static public func makeURL(from date: Date) -> URL { //DataManager에서 [String:[Cafe]]에 사용
        let targetDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
        let targetURLString = """
https://snuco.snu.ac.kr/ko/\
foodmenu?field_menu_date_value_1%5Bvalue%5D%5Bdate%5D=&field_menu_date_value%5Bvalue%5D%5Bdate%5D=
"""
            + String(targetDate.month!) + "%2F" + String(targetDate.day!) + "%2F" + String(targetDate.year!)
        if let targetURL = URL(string: targetURLString) {
            return targetURL
        } else {
            assertionFailure("문자열을 URL로 변환하는데 실패하였습니다\(targetURLString).")
            return URL(string: "https://snuco.snu.ac.kr/ko/foodmenu")!
        }
    }
    
    /// Parse URL with SwiftSoup
    ///
    /// - Note: Public because parsing also used at OurhomeManager
    static public func parse(_ uRL: URL) throws -> Document {
        let uRLContents = try String(contentsOf: uRL)
        let parsedURLContents: Document = try SwiftSoup.parse(uRLContents)
        return parsedURLContents
    }
    
}
