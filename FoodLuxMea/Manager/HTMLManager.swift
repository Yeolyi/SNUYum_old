//
//  HTMLManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import SwiftSoup

class HTMLManager {
    
    func cafeData(at date: Date) -> [Cafe]{
        var cafeData: [Cafe] = []
        let targetURL = makeURL(from: date)
        let parsedDocument = parse(targetURL) //파싱
        
        
        do {
            let rawCafeList: [Element] = try parsedDocument.select("div.view-content").select("tbody").select("tr").array() //식당 배열 [학관, 자하연, 3식당,,] 생성
            
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
            assertionFailure("HTMLManager/getCafeData(from: ): Html 소스 분리에 실패하였습니다.")
        }
        
        
        return []
    }
    
    private func SplitCafeData(_ rawCafe: Element) -> (name: String, callNum: String, rawBreakfasts: String, rawLunches: String, rawDinners: String){
        do {
            let rawCafeArray = try rawCafe.select("td").array() //식당 구성요소 배열 [이름전번, 아침, 점심, 저녁] 생성
            guard rawCafeArray.count == 4 else {
                assertionFailure("HTMLManager/process: 구성요소가 4개가 아닙니다.")
                return ("로딩 실패😢"," "," "," "," ")
            }
            let nameNum = try rawCafeArray[0].text() //[학생회관식당(880-5543)]
            let (cafeName, cafeCallNum) = separateNameNum(nameNum) //이름 전번 분할
            
            let rawBreakfasts = try rawCafeArray[1].select("p").text()
            let rawLunches = try rawCafeArray[2].select("p").text()
            let rawDinners = try rawCafeArray[3].select("p").text()
            return (cafeName, cafeCallNum, rawBreakfasts, rawLunches, rawDinners)
        }
        catch {
            assertionFailure("HTMLManager/process(): 문자열 처리에 실패하였습니다.")
        }
        return ("로딩 실패😢"," "," "," "," ")
    }
    
    private func separateNameNum(_ str: String) -> (name: String, callNum: String){
        let tempArr = str.components(separatedBy: ["("])
        guard tempArr.count == 2 else {
            assertionFailure("HTMLManager/divideNameNCallNum: 구성요소가 두개가 아닙니다.")
            return ("로딩 실패😢"," ")
        }
        let name = String(tempArr[0])
        let callNum = String(tempArr[1].dropLast()) //마지막 괄호 제거
        return (name, callNum)
    }
        
    
    
    
    private func splitMenuList(_ continuousMenus: String) -> [Menu]{ //메뉴 가격 Menu 구조체로 변환. 핵심
        
        func whiteSpaceTrim(_ str: String) -> String {
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        func decimalTrimInverted(_ str: String) -> String {
            return str.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        }
        
        let trimmedContinuousMenus = whiteSpaceTrim(continuousMenus)
        
        if trimmedContinuousMenus.count < 3 {
            return []
        }
        
        var menuList: [Menu] = []
        var startIndex = trimmedContinuousMenus.startIndex
        var isGettingCost  = false
        var menuName: String = ""
        var isTitle = false
        var isTitle2 = false
        var isPass = false
        
        
        for index in trimmedContinuousMenus.indices {
            
            if isPass {
                isPass = false
                continue
            }
            
            
            if isTitle && trimmedContinuousMenus[index] == ">" {
                menuName = whiteSpaceTrim(menuName)
                menuName = String(trimmedContinuousMenus[startIndex...index])
                menuList.append(.init(name: menuName, cost: -1))
                isTitle = false
                startIndex = trimmedContinuousMenus.index(after: index)
                continue
            }
            
            if isTitle {
                continue
            }
            
            if trimmedContinuousMenus[index] == "<" && trimmedContinuousMenus[trimmedContinuousMenus.index(index, offsetBy: 2)] != ">" {
                startIndex = index
                isTitle = true
                continue
            }
            
            if isTitle2 && trimmedContinuousMenus[index] == ")" {
                menuName = whiteSpaceTrim(menuName)
                menuName = String(trimmedContinuousMenus[startIndex...index])
                menuList.append(.init(name: menuName, cost: -1))
                isTitle2 = false
                startIndex = trimmedContinuousMenus.index(after: index)
                continue
            }
            
            if isTitle2 {
                continue
            }
            
            if trimmedContinuousMenus[index] == "(" && trimmedContinuousMenus[trimmedContinuousMenus.index(index, offsetBy: 2)] != ")" {
                startIndex = index
                isTitle2 = true
                continue
            }
            
            
            
            
            if isGettingCost {
                
                
                if index == trimmedContinuousMenus.index(before: trimmedContinuousMenus.endIndex) {
                    var menuCostString = String(trimmedContinuousMenus[startIndex...])
                    menuCostString = menuCostString.components(separatedBy: [",", " ", "원"]).joined()
                    if let tempMenuCost = Int(menuCostString) {
                        menuList.append(.init(name: menuName, cost: tempMenuCost))
                        return menuList
                    }
                    else {
                        assertionFailure("HTMLManager/splitMenuList: \(menuCostString) 가격을 INT로 변환할 수 없습니다.")
                    }
                }
                
                
                if String(trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)]) == "," ||
                    String(trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)]) == " " ||
                    String(trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)]) == "원" || Int(String(trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)])) != nil {
                    continue
                }
                else {
                    var menuCostString = String(trimmedContinuousMenus[startIndex...index])
                    menuCostString = menuCostString.components(separatedBy: [",", " ", "원"]).joined()
                    if let tempMenuCost = Int(menuCostString) {
                        if trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)] == "~" {
                            let amenuCost = tempMenuCost + 10
                            menuList.append(.init(name: menuName, cost: amenuCost))
                            startIndex = trimmedContinuousMenus.index(index, offsetBy: 2)
                            isGettingCost = false
                            continue
                        }
                        menuList.append(.init(name: menuName, cost: tempMenuCost))
                        startIndex = index
                        isGettingCost = false
                    }
                    else {
                        assertionFailure("HTMLManager/splitMenuList: \(menuCostString) 가격을 INT로 변환할 수 없습니다.")
                    }
                }
                
                
            }
            
            if Int(String(trimmedContinuousMenus[index])) != nil {
                guard String(trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)]) == "," || Int(String(trimmedContinuousMenus[trimmedContinuousMenus.index(after: index)])) != nil else {
                    continue
                }
                
                menuName = String(trimmedContinuousMenus[startIndex..<index])
                menuName = whiteSpaceTrim(menuName)
                startIndex = index
                isGettingCost = true
            }
            
            if index == trimmedContinuousMenus.index(before: trimmedContinuousMenus.endIndex) {
                let trimmedResidue = whiteSpaceTrim(String(trimmedContinuousMenus[startIndex...]))
                if trimmedResidue.count > 3 {
                    menuList.append(.init(name: trimmedResidue, cost: -1))
                }
                return menuList
            }
        }
    

        //var replaced = trimmedContinuousMenus.replacingOccurrences(of: "00원~", with: "10원") //물결표시 ~원 이상으로 바꾸기 위함
        //replaced = replaced.replacingOccurrences(of: "0원", with: "꿇") //아래 components 함수가 한글자로만 작동함
        
        //let menuArray = replaced.components(separatedBy: ["꿇", ">"]) //원과 >으로 나눠 배열 생성
         assertionFailure("여기까지 오면 안돼요")
        return menuList
    }
    private func parse(_ uRL: URL) -> Document {
        do {
            let uRLContents = try String(contentsOf: uRL)
            let parsedURLContents: Document = try SwiftSoup.parse(uRLContents)
            return parsedURLContents
        }
        catch {
            assertionFailure("HTMLManager/parse(): URL 파싱에 실패하였습니다.")
        }
        return .init("https://snuco.snu.ac.kr/ko/foodmenu")
    }
    
}


func makeURL(from date: Date) -> URL { //DataManager에서 [String:[Cafe]]에 사용
    let targetDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
    let targetURLString = "https://snuco.snu.ac.kr/ko/foodmenu?field_menu_date_value_1%5Bvalue%5D%5Bdate%5D=&field_menu_date_value%5Bvalue%5D%5Bdate%5D=" + String(targetDate.month!) + "%2F" + String(targetDate.day!) + "%2F" + String(targetDate.year!)
    if let targetURL = URL(string: targetURLString) {
        return targetURL
    }
    else{
        assertionFailure("HTMLManager/makeURL(from: ): 문자열을 URL로 변환하는데 실패하였습니다.")
        return URL(string: "https://snuco.snu.ac.kr/ko/foodmenu")!
    }
}
