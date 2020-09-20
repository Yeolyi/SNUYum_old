//
//  CafeStruct.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/// Data of a single cafeteria.
///
/// Includes cafe name, cafe phone number, three meals' menus.
///
/// - Note: Hashable protocol to make Menu array.
///
/// Codable protocol to encoded/decoded while using Userdefault.
///
/// Identifiable adopted to give id in list view.
///
/// - ToDo: As phoneNum variable is available in another struct, delete it and let settingmanager
/// manage it. Also change name of bkfMenuList to breakfastMenuList.
struct Cafe: Hashable, Codable, Identifiable {
  
  internal var id = UUID()
  
  let name: String
  public let phoneNum: String
  
  private let bkfMenuList: [Menu]
  private let lunchMenuList: [Menu]
  private let dinnerMenuList: [Menu]
  
  init(name: String) {
    self.name = name
    self.phoneNum = phoneNumList[name] ?? ""
    self.bkfMenuList = []
    self.lunchMenuList = []
    self.dinnerMenuList = []
  }
  
  init(name: String, phoneNum: String, bkfMenuList: [Menu], lunchMenuList: [Menu], dinnerMenuList: [Menu]) {
    if name.isEmpty {
      assertionFailure("Invalid name\(name)")
    }
    self.name = name
    self.phoneNum = phoneNum
    self.bkfMenuList = bkfMenuList
    self.lunchMenuList = lunchMenuList
    self.dinnerMenuList = dinnerMenuList
  }
  
   /// True if there is no menu in selected meal type.
   ///
   /// - Parameters:
   ///  - mealType: Select which meal type to search
   ///  - emptyKeywords: Exceptional strings which means menu is empty.
  func isEmpty(at mealTypes: [MealType], emptyKeywords: [String]) -> Bool {
    for mealType in mealTypes {
      let menuList = menus(at: mealType)
      if menuList.isEmpty { continue }
      for menu in menuList {
        var tempEmpty = false
        for keyword in emptyKeywords {
          if menu.name.contains(keyword) { tempEmpty = true }
        }
        if tempEmpty == false {
          return false
        }
      }
    }
    return true
  }
  
  
   /// Get menu list of selected meal type
   ///
   /// - Parameter mealType: Select which meal type to get
  func menus(at mealType: MealType) -> [Menu] {
    switch mealType {
    case .breakfast:
      return bkfMenuList
    case .lunch:
      return lunchMenuList
    case .dinner:
      return dinnerMenuList
    }
  }
  
   /// True if cafe name or meal array contains searching text
   ///
   /// - Parameter keyword: Text to search.
   /// - Parameter mealType: Meal type array to search.
  func includes(_ keyword: String, at mealTypes: [MealType]) -> Bool {
    for mealType in mealTypes {
      let menuList = menus(at: mealType)
      for menu in menuList{
        if (menu.name.contains(keyword)) {
          return true
        }
      }
    }
    return false
  }
}
