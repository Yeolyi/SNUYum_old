//
//  HTMLManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import SwiftSoup

/// Parse URL with SwiftSoup
func parse(_ uRL: URL) -> Document {
    do {
        let uRLContents = try String(contentsOf: uRL)
        let parsedURLContents: Document = try SwiftSoup.parse(uRLContents)
        return parsedURLContents
    }
    catch {
        assertionFailure("SNUCOManager/parse(): URL 파싱에 실패하였습니다.")
    }
    return .init("https://snuco.snu.ac.kr/ko/foodmenu")
}


/// Get data from snuco website and process into Cafe struct
class SNUCOManager {
    
    /// Get Cafe array from specific date; sum of below functions
    func getAll(at date: Date) -> [Cafe]{
        var cafeData: [Cafe] = []
        let targetURL = makeURL(from: date)
        let parsedDocument = parse(targetURL) //파싱
        
        
        do {
            let rawCafeList: [Element] = try
                //식당 배열 [학관, 자하연, 3식당,,] 생성
                parsedDocument.select("div.view-content").select("tbody").select("tr").array()
            
            for rawCafe in rawCafeList { 
                let tempCafe = SplitCafeData(rawCafe)
                let breakfastMenus = splitMenuList(tempCafe.rawBreakfasts) //메뉴 가격 Menu 구조체로 변환
                let lunchMenus = splitMenuList(tempCafe.rawLunches)
                let dinnerMenus = splitMenuList(tempCafe.rawDinners)
                cafeData.append(.init(name: tempCafe.name, phoneNum: tempCafe.callNum, bkfMenuList: breakfastMenus, lunchMenuList: lunchMenus, dinnerMenuList: dinnerMenus))
            }
            return cafeData
        }
            
            
        catch {
            assertionFailure("SNUCOManager/getCafeData(from: ): Html 소스 분리에 실패하였습니다.")
        }
        
        
        return []
    }
    
    /// Simply divide whole URL Element to cafe struct elements
    private func SplitCafeData(_ rawCafe: Element) -> (name: String, callNum: String, rawBreakfasts: [Element], rawLunches: [Element], rawDinners: [Element]){
        do {
            let rawCafeArray = try rawCafe.select("td").array() //식당 구성요소 배열 [이름전번, 아침, 점심, 저녁] 생성
            guard rawCafeArray.count == 4 else {
                assertionFailure("SNUCOManager/process: 구성요소가 4개가 아닙니다.")
                return ("로딩 실패😢"," ",[], [], [])
            }
            let nameNum = try rawCafeArray[0].text() //[학생회관식당(880-5543)]
            let (cafeName, cafeCallNum) = separateNameNum(nameNum) //이름 전번 분할
            
            let rawBreakfasts = try rawCafeArray[1].select("p").array()
            let rawLunches = try rawCafeArray[2].select("p").array()
            let rawDinners = try rawCafeArray[3].select("p").array()
            return (cafeName, cafeCallNum, rawBreakfasts, rawLunches, rawDinners)
        }
        catch {
            assertionFailure("SNUCOManager/process(): 문자열 처리에 실패하였습니다.")
        }
        return ("로딩 실패😢"," ",[], [], [])
    }
    
    private func separateNameNum(_ str: String) -> (name: String, callNum: String){
        let tempArr = str.components(separatedBy: ["("])
        guard tempArr.count == 2 else {
            assertionFailure("SNUCOManager/divideNameNCallNum: 구성요소가 두개가 아닙니다.")
            return ("로딩 실패😢"," ")
        }
        let name = String(tempArr[0])
        let callNum = String(tempArr[1].dropLast()) //마지막 괄호 제거
        return (name, callNum)
    }
        
    /// Get cost and menu name from elements; important function
    private func splitMenuList(_ menuList: [Element]) -> [Menu] {
        
        var returnValue: [Menu] = []
        
        func whiteSpaceTrim(_ str: String) -> String {
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        func decimalTrimInverted(_ str: String) -> Int {
            return Int(str.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
        }
        
        for rawMenu in menuList {
            var temp = try! rawMenu.html()
            temp = temp.replacingOccurrences(of: "<br>", with: "꿇")
            temp = try! SwiftSoup.parse(temp).text()
            let list = temp.split(separator: "꿇").map(String.init)
            for i in list { //여기서 메뉴와 가격 분리
                print(i)
                let trimmedValue = whiteSpaceTrim(i)
                
                if trimmedValue.isEmpty {
                    continue
                }
                
                else if (trimmedValue[trimmedValue.startIndex] == "※") {
                    continue
                }
                else if (trimmedValue[trimmedValue.startIndex] == "<") {
                    returnValue.append(.init(name: trimmedValue, cost: -1))
                    continue
                }
                
                var isCost = false
                
                for index in trimmedValue.indices {
                    if Int(String(trimmedValue[index])) != nil && (String(trimmedValue[trimmedValue.index(after: index)]) == "," || Int(String(trimmedValue[trimmedValue.index(after: index)])) != nil) {
                        let menu = whiteSpaceTrim(String(trimmedValue[..<index]))
                        let cost = decimalTrimInverted(whiteSpaceTrim(String(trimmedValue[index...])))
                        print("\(menu) \(cost)")
                        returnValue.append(.init(name: menu, cost: cost))
                        isCost = true
                        break
                    }
                }
                
                if isCost == false {
                    returnValue.append(.init(name: trimmedValue, cost: -1))
                }
            }
            
        }
        print(returnValue)
        return returnValue
    }
    
    /// Make URL which has access to input date's data
    func makeURL(from date: Date) -> URL { //DataManager에서 [String:[Cafe]]에 사용
        let targetDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
        let targetURLString = "https://snuco.snu.ac.kr/ko/foodmenu?field_menu_date_value_1%5Bvalue%5D%5Bdate%5D=&field_menu_date_value%5Bvalue%5D%5Bdate%5D=" + String(targetDate.month!) + "%2F" + String(targetDate.day!) + "%2F" + String(targetDate.year!)
        if let targetURL = URL(string: targetURLString) {
            return targetURL
        }
        else{
            assertionFailure("SNUCOManager/makeURL(from: ): 문자열을 URL로 변환하는데 실패하였습니다.")
            return URL(string: "https://snuco.snu.ac.kr/ko/foodmenu")!
        }
    }
    
}



