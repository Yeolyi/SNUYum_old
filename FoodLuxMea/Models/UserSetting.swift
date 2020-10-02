//
//  SettingManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/25.
//

import SwiftUI

/// Saves and loads overall user settings and mediates/applies them.
///
/// Important: If variable name changes, userdefault crashes when accessing previous setting.
///
/// - ToDo: Make version compatible - solution to userdefault error
class UserSetting: ObservableObject {
    
    /// Current meal view mode in main view; breakfast only, lunch only or dinner only.
    ///
    /// - Important: Overwritten when 'isAuto' is true!
    ///
    /// - Memo: 아 private으로 맞춰놓을걸;; meal 써야되는데 이거 써버림
    @Published var mealViewMode: MealType = .lunch
    
    /// Turn on meal type suggestion.
    @Published var isAuto: Bool = true
    
    /// Activate custom date which makes whole app uses fixed date.
    @Published var isCustomDate: Bool = false
    
    /// Date variable used when isCustomDate is true.
    @Published var debugDate: Date = Date()
    
    /// If true, filter empty cafes in list.
    @Published var hideEmptyCafe: Bool = true
    
    /// Suggested meal type based on current setting time.
    ///
    /// - Important: Should be updated when setting time or timer cafe changes.
    @Published var suggestedMeal: MealType = .lunch
    
    /// Tell if next day of setting day should be suggested.
    ///
    /// - Important: Should be updated when setting time or timer cafe changes.
    @Published var isSuggestedTomorrow: Bool = false
    
    /// Main view timer cafe name; nil if timer is set to be hidden.
    @Published var alimiCafeName: String? = "학생회관식당" 
    
    /// Final cafe date considering custom date and date suggestion.
    var date: Date {
        var date = isCustomDate ? debugDate : Date()
        if isSuggestedTomorrow {
            var dayComponent    = DateComponents()
            dayComponent.day    = 1
            let theCalendar     = Calendar.current
            date = theCalendar.date(byAdding: dayComponent, to: date)!
        }
        return date
    }
    
    /// Final meal type considering isAuto.
    var meal: MealType {
        isAuto ? suggestedMeal : mealViewMode
    }
    
    /// If setting data is stored, retrieve it
    ///
    /// - Note: If it's app's first run, save default value and return.
    init() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            let settingInitialized = userDefaults.bool(forKey: "firstRun")
            if settingInitialized == false {
                print("First setting initializing, quitting init now.")
                userDefaults.set(true, forKey: "firstRun")
                return
            }
            if let storedMealViewMode = MealType(rawValue: userDefaults.string(forKey: "mealViewMode") ?? "점심") {
                mealViewMode = storedMealViewMode
            }
            alimiCafeName = userDefaults.string(forKey: "timerCafeName")
            isAuto = userDefaults.bool(forKey: "isAuto")
            hideEmptyCafe = userDefaults.bool(forKey: "isHide")
            print("Setting loaded.")
        } else {
            assertionFailure("SettingManager/init(): UserDefault를 불러오지 못했습니다.")
        }
    }
    
    func clear() {
        mealViewMode = .lunch
        isAuto = true
        isCustomDate = false
        debugDate = Date()
        hideEmptyCafe = true
        alimiCafeName = "학생회관식당"
        update()
    }
    
    func save() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            userDefault.set(mealViewMode.rawValue as String, forKey: "mealViewMode")
            userDefault.set(isAuto as Bool, forKey: "isAuto")
            userDefault.set(hideEmptyCafe as Bool, forKey: "isHide")
            userDefault.set(alimiCafeName as String?, forKey: "timerCafeName")
            print("Setting Saved.")
        } else {
            print("세팅 저장 안됨")
        }
    }
    
    /// Update setting if timer cafe changes. 
    func update() {
        (isSuggestedTomorrow, suggestedMeal) = DailyProposer.menu(at: date, cafeName: alimiCafeName ?? "3식당")
        print("SettingManager updated.")
    }
}
