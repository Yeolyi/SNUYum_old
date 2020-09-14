//
//  SettingManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/25.
//

import SwiftUI

/**
 Manages overall user settings.
 
 - ToDo: Make version compatible - solution to userdefault error
 */
class SettingManager: ObservableObject {
    
    @Published var mealViewMode: MealType = .lunch
    @Published var widgetMealViewMode: MealType = .lunch
    @Published var isAuto: Bool = true
    @Published var isWidgetAuto: Bool = true
    @Published var isCustomDate: Bool = false
    @Published var debugDate: Date = Date()
    @Published var hideEmptyCafe: Bool = true
    @Published var suggestedMeal: MealType = .lunch
    @Published var isSuggestedTomorrow: Bool = false
    @Published var alimiCafeName: String? = "학생회관식당"
    
    var closedKeywords = ["방학중휴점", "폐    점", "코로나19로 당분간 휴점", "방학중 휴무", "당분간 폐점", "폐  점"] 
    
    private var smartSuggestion = SmartSuggestion()

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
    
    var meal: MealType {
        isAuto ? suggestedMeal : mealViewMode
    }
    
    /// If setting data is stored, retrieve it
    init() {
        isSuggestedTomorrow = smartSuggestion.isTomorrow(Date())
        suggestedMeal = smartSuggestion.mealType(at: Date())
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if userDefaults.bool(forKey: "firstRun") == false {
                save()
                return
            }
            mealViewMode = MealType(rawValue: userDefaults.string(forKey: "mealViewMode")!)!
            widgetMealViewMode = MealType(rawValue: userDefaults.string(forKey: "widgetMealViewMode")!)!
            debugDate = strToDate(userDefaults.string(forKey: "debugDate")!)
            alimiCafeName = userDefaults.string(forKey: "timerCafeName") ?? nil
            isAuto = userDefaults.bool(forKey: "isAuto")
            isWidgetAuto = userDefaults.bool(forKey: "isWidgetAuto")
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
            userDefault.set(widgetMealViewMode.rawValue as String, forKey: "widgetMealViewMode")
            userDefault.set(isAuto as Bool, forKey: "isAuto")
            userDefault.set(isWidgetAuto as Bool, forKey: "isWidgetAuto")
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
    
    /// If date is changed suggested value should also be updated
    func update(date: Date) {
        if let cafeName = alimiCafeName {
            smartSuggestion.update(dailyOperatingHour: cafeOperatingHour[cafeName]?.dayOfTheWeek(date: date))
        }
        isSuggestedTomorrow = smartSuggestion.isTomorrow(date)
        suggestedMeal = smartSuggestion.mealType(at: date)
        print("SettingManager/update(date: ): 추천값 업데이트 완료")
    }
}
