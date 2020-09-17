//
//  CafeStruct.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import Foundation

/**
 Indicates one of these three meals; breakfast, lunch and dinner.
 
 Support raw string value in korean.
 
 - Note: Codable protocol adopted to encoded/decoded while using Userdefault.
 */
enum MealType: String, Codable {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
}

/**
 Data of a single menu.
 
 If there's no cost data in server, cost value is -1.
 
 - Precondition: 'cost' variable cannot be negative other than -1.
 
 - Note: Hashable protocol to make Menu array.
 
 Codable protocol to encoded/decoded while using Userdefault.
 
 Identifiable adopted to give id in list view.
 
 - Todo: Change cost type to optional Int to stop using -1.
 */
struct Menu: Hashable, Codable, Identifiable {
    var id = UUID()
    let name: String
    let cost: Int
    
    /**
     Creates an menu struct.
     
     - Parameter cost: Defult value is -1.
     */
    init(name: String, cost: Int = -1) {
        self.name = name
        guard cost >= 0 || cost == -1 else {
            assertionFailure("Menu/init: Inappropriate cost value - \(cost)")
            self.cost = -1
            return
        }
        self.cost = cost
    }
}

/**
 Data of a single cafeteria.
 
 Includes cafe name, cafe phone number, three meals' menus.
 
 - Note: Hashable protocol to make Menu array.
 
 Codable protocol to encoded/decoded while using Userdefault.
 
 Identifiable adopted to give id in list view.
 
 - ToDo: As phoneNum variable is available in another struct, delete it and let settingmanager manage it. Also change name of bkfMenuList to breakfastMenuList.
 */
struct Cafe: Hashable, Codable, Identifiable {
    internal var id = UUID()
    let name: String
    public let phoneNum: String
    private let bkfMenuList: [Menu]
    private let lunchMenuList: [Menu]
    private let dinnerMenuList: [Menu]
    
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
    
    /**
     True if there is no menu in selected meal type.
     
     - Parameters:
        - mealType: Select which meal type to search
        - keywords: Exceptional strings which means menu is empty.
     */
    func isEmpty(at mealTypes: [MealType], emptyKeywords: [String]) -> Bool {
        for mealType in mealTypes {
            let targetMenuList = menus(at: mealType)
            if (targetMenuList.count == 0 ) { return true }
            else if (targetMenuList.count > 1) { return false}
            else {
                for keyword in emptyKeywords {
                    if targetMenuList.contains(where: { $0.name == keyword }) {
                        return true
                    }
                }
                return false
            }
        }
        assertionFailure("Unintended blah blah")
        return false
    }
    
    /**
     Get menu list of selected meal type
     
     - Parameter mealType: Select which meal type to get
    */
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
    
    /**
     True if cafe name or meal array contains searching text
     
     - Parameter keyword: Text to search.
     - Parameter mealType: Meal type array to search.
    */
    func includes(_ keyword: String, at mealTypes: [MealType]) -> Bool {
        for mealType in mealTypes {
            if (name.contains(keyword)) {
                return true
            }
            let menuList = menus(at: mealType)
            for menu in menuList{
                if (menu.name.contains(keyword)) {
                    return true
                }
            }
            return false
        }
        assertionFailure("Unintended Blah Blah")
        return false
    }
}
