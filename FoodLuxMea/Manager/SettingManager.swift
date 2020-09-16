//
//  SettingManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/25.
//

import SwiftUI

/**
 Saves and loads overall user settings and mediates/applies them.
 
 - Important: If variable name changes, userdefault crashes when accessing previous setting.
 
 - ToDo: Make version compatible - solution to userdefault error
 */
class SettingManager: ObservableObject {
    /**
     Current meal view mode in main view; breakfast only, lunch only or dinner only.
     
     - Important: Overwritten when 'isAuto' is true!
     */
    @Published var mealViewMode: MealType = .lunch
    
    /// Turn on meal type suggestion.
    @Published var isAuto: Bool = true
    
    /// Activate custom date which makes whole app uses fixed date.
    @Published var isCustomDate: Bool = false
    
    /// Date variable used when isCustomDate is true.
    @Published var debugDate: Date = Date()
    
    /// If true, filter empty cafes in list.
    @Published var hideEmptyCafe: Bool = true
    
    /**
     Suggested meal type based on current setting time.
     
     - Important: Should be updated when setting time or timer cafe changes.
     */
    @Published var suggestedMeal: MealType = .lunch
    
    /**
    Tell if next day of setting day should be suggested.
    
    - Important: Should be updated when setting time or timer cafe changes.
    */
    @Published var isSuggestedTomorrow: Bool = false
    
    /// Main view timer cafe name; nil if timer is set to be hidden.
    @Published var alimiCafeName: String? = "학생회관식당"
    
    /// Array of string which means there is no menu.
    var closedKeywords = ["방학중휴점", "폐    점", "코로나19로 당분간 휴점", "방학중 휴무", "당분간 폐점", "폐  점"] 
    
    /// Class to calculate remain time and suggest meal type.
    private var smartSuggestion = SmartSuggestion()

    /// Final cafe date considering custom date and date suggestion.
    var date: Date {
        let date = isCustomDate ? debugDate : Date()
        if (isSuggestedTomorrow) {
            var dayComponent    = DateComponents()
            dayComponent.day    = 1
            let theCalendar     = Calendar.current
            return theCalendar.date(byAdding: dayComponent, to: date)!
        }
        else {
            return date
        }
    }
    
    /// Final meal type considering isAuto.
    var meal: MealType {
        isAuto ? suggestedMeal : mealViewMode
    }
    
    /**
     If setting data is stored, retrieve it
     
     - Note: If it's app's first run, save default value and return.
     */
    init() {
        isSuggestedTomorrow = smartSuggestion.isTomorrow(Date())
        suggestedMeal = smartSuggestion.mealType(at: Date())
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if userDefaults.bool(forKey: "firstRun") == false {
                save()
                return
            }
            mealViewMode = MealType(rawValue: userDefaults.string(forKey: "mealViewMode")!)!
            debugDate = strToDate(userDefaults.string(forKey: "debugDate")!)
            alimiCafeName = userDefaults.string(forKey: "timerCafeName") ?? nil
            isAuto = userDefaults.bool(forKey: "isAuto")
            isCustomDate = userDefaults.bool(forKey: "isDebug")
            hideEmptyCafe = userDefaults.bool(forKey: "isHide")
            print("SettingManager/init(): 설정값을 불러왔습니다.")
        }
        else {
            assertionFailure("SettingManager/init(): UserDefault를 불러오지 못했습니다.")
        }
    }
    
    func save() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea"){
            userDefault.set(mealViewMode.rawValue as String, forKey: "mealViewMode")
            userDefault.set(isAuto as Bool, forKey: "isAuto")
            userDefault.set(true as Bool, forKey: "firstRun")
            userDefault.set(isCustomDate as Bool, forKey: "isDebug")
            userDefault.set(hideEmptyCafe as Bool, forKey: "isHide")
            userDefault.set(dateToStr(debugDate) as String, forKey: "debugDate")
            if alimiCafeName != nil {
                userDefault.set(alimiCafeName! as String, forKey: "timerCafeName")
            }
        }
        print("SettingManaver/save(): 세팅 저장됨")
    }
    
    /// Update setting if timer cafe changes. 
    func update(date: Date) {
        if let cafeName = alimiCafeName {
            smartSuggestion.update(dailyOperatingHour: cafeOperatingHour[cafeName]?.dayOfTheWeek(date: date))
        }
        isSuggestedTomorrow = smartSuggestion.isTomorrow(date)
        suggestedMeal = smartSuggestion.mealType(at: date)
        print("SettingManager/update(date: ): 추천값 업데이트 완료")
    }
}
