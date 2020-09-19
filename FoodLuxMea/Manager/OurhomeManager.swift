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
/// - Note: Ourhome data uses one cafe struct. 
class OurhomeManager {
  
  var cafeData: [URL : [Int : Cafe]] = [:]
  /// Unnessessary data position in ourhome HTML
  private let isIgnore: [[Bool]] = [
    [true, true, true, false, false, false, false, false, false, false],
    [true, false, false, false, false, false, false, false],
    [true, true, false, false, false, false, false, false, false],
    [true, false, false, false, false, false, false, false],
    [true, false, false, false, false, false, false, false],
    [true, true, false, false, false, false, false, false, false],
    [true, false, false, false, false, false, false, false],
    [true, false, false, false, false, false, false, false]]
  
  /// Cafe order and meal type indexes in ourhome HTML
  private let cafeNameOrder = ["가마", "인터쉐프", "가마", "인터쉐프", "해피존", "가마", "인터쉐프", "해피존"]
  private let bkfIndex = [0, 1]
  private let lunchIndex = [2, 3, 4]
  private let dinnerIndex = [5, 6, 7]
  
  init() {
    if let loadedData = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea")?.value(forKey: "ourhomeData") as? Data {
      cafeData = try! PropertyListDecoder().decode([URL : [Int : Cafe]].self, from: loadedData)
      print("OurhomeManager/init(): ourhomeData가 로드되었습니다")
    }
  }
  
  /// Save retrieved data for loading time optimization
  func save() {
    if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea"){
      if let encodedData = try? PropertyListEncoder().encode(cafeData) {
        userDefault.set(encodedData, forKey: "ourhomeData")
        print("OurhomeManager/save(): ourhomeData가 저장되었습니다")
      }
      else {
        print("OurhomeManager/save(): 데이터 인코딩에 실패했습니다.")
      }
    }
    else {
      print("OurhomeManager/save(): UserDefaults 로딩에 실패했습니다.")
    }
  }
  
  
  func getCafe(date: Date) -> Cafe {
    if let data = cafeData[makeURL(from: date)] {
      let dayOfTheWeek = getDayOfWeek(date)
      return data[dayOfTheWeek]!
    }
    else {
      cafeData[makeURL(from: date)] = loadCafe(date: date)
      let data = cafeData[makeURL(from: date)]!
      let dayOfTheWeek = getDayOfWeek(date)
      save()
      return data[dayOfTheWeek]!
    }
  }
  
  /// Get day of week from input date and convert it into Int
  func getDayOfWeek(_ date: Date) -> Int {
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: date)
    return weekDay - 1
  }
  
  func loadCafe(date: Date) -> [Int : Cafe]{
    var cafeList: [Int : Cafe] = [:]
    var cafeDayofWeek: [Int: [Menu]] = [:]
    
    for i in 0..<8 {
      cafeDayofWeek[i] = []
    }
    
    let uRLContents = makeURL(from: date)
    let parsed = parse(uRLContents)
    
    print("OurhomeManager/loadCafe: 아워홈 정보 불러오는 중,,,")
    
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
          if menu != "" {
            cafeDayofWeek[dayCount]!.append(Menu(name: "(\(cafeNameOrder[rowNum]))\(menu)", cost: cost))
          }
          else {
            cafeDayofWeek[dayCount]!.append(Menu(name: "", cost: -1))
          }
          dayCount += 1
        }
      }
    }
    for day in 0..<7 {
      var tempBkfMenuList: [Menu] = []
      var tempLunchMenuList: [Menu] = []
      var tempDinnerMenuList: [Menu] = []
      for i in bkfIndex {
        let tempMenu = cafeDayofWeek[day]![i]
        if tempMenu.cost != -1 {
          tempBkfMenuList.append(tempMenu)
        }
      }
      for i in lunchIndex {
        let tempMenu = cafeDayofWeek[day]![i]
        if tempMenu.cost != -1 {
          tempLunchMenuList.append(tempMenu)
        }
      }
      for i in dinnerIndex {
        let tempMenu = cafeDayofWeek[day]![i]
        if tempMenu.cost != -1 {
          tempDinnerMenuList.append(tempMenu)
        }
      }
      cafeList[day] = Cafe(name: "아워홈", phoneNum: "", bkfMenuList: tempBkfMenuList, lunchMenuList: tempLunchMenuList, dinnerMenuList: tempDinnerMenuList)
    }
    return cafeList
  }
  
  func makeURL(from date: Date) -> URL {
    let baseNum = 1597503600
    let baseDate = trimDate(using: "2020/08/16 00:00")
    let components = Calendar.current.dateComponents([.weekOfYear], from: baseDate, to: date)
    //print("\(baseDate)부터 \(date)까지 \(components.weekOfYear!)주 지났습니다")
    return URL(string: "https://dorm.snu.ac.kr/dk_board/facility/food.php?start_date2=\(baseNum + components.weekOfYear! * 60 * 60 * 24 * 7)")!
  }
  
  /// Convert HTML class attrubution to cost value
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
  
  /// Convert yyyy/MM/dd HH:mm style string to Date
  func trimDate(using string: String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let date = formatter.date(from: string)!
    guard let trimmedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) else {
      assertionFailure("")
      return Date()
    }
    return trimmedDate
  }
  
}
