//
//  SettingManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/25.
//

import SwiftUI

/// Saves and loads overall user settings and mediates/applies them.
class UserSetting: ObservableObject {
    
    /// Current meal view mode in main view; breakfast only, lunch only or dinner only.
    ///
    /// - Important: Overwritten when 'isAuto' is true.
    @AutoSave("mealViewMode", defaultValue: .lunch)
    var mealViewMode: MealType {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AutoSave("showMealSelectView", defaultValue: false)
    var showMealSelectView: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    /// Turn on meal type suggestion.
    @AutoSave("isAuto", defaultValue: true)
    var isAuto: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    /// Activate custom date which makes whole app uses fixed date.
    @Published var isDebugDate: Bool = false
    
    /// Date variable used when isCustomDate is true.
    @Published var debugDate: Date = Date()
    
    /// If true, filter empty cafes in list.
    @AutoSave("isHide", defaultValue: true)
    var hideEmptyCafe: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    /// Suggested meal type based on current setting time.
    ///
    /// - Important: Should be updated when setting time or timer cafe changes.
    @Published var suggestedMeal: MealType = .lunch
    
    /// Tell if next day of setting day should be suggested.
    ///
    /// - Important: Should be updated when setting time or timer cafe changes.
    @Published var isSuggestedTomorrow: Bool = false
    
    /// Main view timer cafe name; nil if timer is set to be hidden.
    @AutoSave("timerCafeName", defaultValue: "학생회관식당")
    var alimiCafeName: String? {
        willSet {
            objectWillChange.send()
        }
        didSet {
            update()
        }
    }
    
    /// Final cafe date considering custom date and date suggestion.
    var date: Date {
        var date = isDebugDate ? debugDate : Date()
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
    
    func clear() {
        mealViewMode = .lunch
        isAuto = true
        isDebugDate = false
        debugDate = Date()
        hideEmptyCafe = true
        alimiCafeName = "학생회관식당"
        update()
    }

    func update() {
        isSuggestedTomorrow = DailyProposer(at: date, cafeName: alimiCafeName ?? "3식당").isTomorrow
        suggestedMeal = DailyProposer(at: date, cafeName: alimiCafeName ?? "3식당").meal
        print("SettingManager updated.")
    }
}
