//
//  Ourhome Manager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/05.
//

import SwiftSoup
import SwiftUI


//0: Sun - 6:Sat
class OurhomeManager {
    
    var nameList = ["가마", "인터쉐프", "해피존"]
    var cafeData: [URL : [Int : [Cafe]]] = [:]
    private let isIgnore: [[Bool]] = [
        [true, true, true, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false],
        [true, true, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false],
        [true, true, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false]]
    
    
    init() {
        cafeData[makeURL(from: Date())] = loadCafe(date: Date())
    }
    
    func getCafe(date: Date) -> [Cafe] {

        if let data = cafeData[makeURL(from: date)] {
            let dayOfTheWeek = getDayOfWeek(date)
            return data[dayOfTheWeek]!
        }
        else {
            cafeData[makeURL(from: date)] = loadCafe(date: date)
            let data = cafeData[makeURL(from: date)]!
            let dayOfTheWeek = getDayOfWeek(date)
            return data[dayOfTheWeek]!
        }
    }
    
    func getDayOfWeek(_ date: Date) -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        return weekDay - 1
    }
    
    
    func loadCafe(date: Date) -> [Int : [Cafe]]{
        var cafeList: [Int : [Cafe]] = [:]
        var cafeDayofWeek: [Int: [[Menu]]] = [:]
        
        for i in 0..<7 {
            cafeDayofWeek[i] = []
        }

        let uRLContents = makeURL(from: date)
        let parsed = parse(uRLContents)

        //가로줄 구분
        let rawCafeList = try! parsed.select("div#container").select("tbody").select("tr").array()
        
        var dayCount = 0
        //가로즐 순회
        for rowNum in 0..<8 {
            dayCount = 0
            let horizontal = rawCafeList[rowNum]
            let mealArray = try! horizontal.select("td").array()
            for columnNum in 0..<isIgnore[rowNum].count {
                if isIgnore[rowNum][columnNum] == false {
                    let menu = try! mealArray[columnNum].select("li").text()
                    let cost = getCost(menuName: try! mealArray[columnNum].select("li").attr("class"))
                    if menu != "" && cost != 0 {
                        cafeDayofWeek[dayCount]!.append([Menu(name: menu, cost: cost)])
                    }
                    else {
                        cafeDayofWeek[dayCount]!.append([])
                    }
                    dayCount += 1
                }
            }
        }

        for day in 0..<7 {
            cafeList[day] = [
                Cafe(name: "가마", phoneNum: "", bkfMenuList: cafeDayofWeek[day]![0], lunchMenuList: cafeDayofWeek[day]![2], dinnerMenuList: cafeDayofWeek[day]![5]),
                Cafe(name: "인터쉐프", phoneNum: "", bkfMenuList: cafeDayofWeek[day]![1], lunchMenuList: cafeDayofWeek[day]![3], dinnerMenuList: cafeDayofWeek[day]![6]),
                Cafe(name: "해피존", phoneNum: "", bkfMenuList: [], lunchMenuList: cafeDayofWeek[day]![4], dinnerMenuList: cafeDayofWeek[day]![7])
            ]
        }
        return cafeList
    }
    
    
    func makeURL(from date: Date) -> URL {
        let baseNum = 1597503600
        let baseDate = getTrimmedDate(from: "2020/08/16 00:00")
        let components = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date)
        //print("\(baseDate)부터 \(date)까지 \(components.weekOfYear!)주 지났습니다")
        return URL(string: "https://dorm.snu.ac.kr/dk_board/facility/food.php?start_date2=\(baseNum + components.weekOfYear! * 604800)")!
    }

    func parse(_ uRL: URL) -> Document {
        do {
            let uRLContents = try String(contentsOf: uRL)
            let parsedURLContents: Document = try SwiftSoup.parse(uRLContents)
            return parsedURLContents
        }
        catch {
            assertionFailure("HTMLManager/parse(): URL 파싱에 실패하였습니다.")
        }
        return .init("https://dorm.snu.ac.kr/dk_board/facility/food.php")
    }

    func getCost(menuName: String) -> Int {
        switch menuName {
        case "menu_a":
            return 2000
        case "menu_b":
            return 2500
        case "menu_c":
            return 3000
        case "menu_d":
            return 3500
        case "menu_e":
            return 4000
        case "menu_f":
            return 5000
        default:
            return 0
        }
    }
}
