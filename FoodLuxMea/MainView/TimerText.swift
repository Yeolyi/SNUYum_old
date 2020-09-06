//
//  Alami.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

struct TimerText: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()
    let cafeName: String
    
    var body: some View {
        Text(text())
    }
    
    func text() -> String {
        let currentHour = Calendar.current.component(.hour, from: settingManager.date)
        let currentMinute = Calendar.current.component(.minute, from: settingManager.date)
        
        a: if let endDate = cafeOperatingHour[cafeName]?.dayOfTheWeek(date: settingManager.date)?.mealTypeToEndTime(settingManager.suggestedMeal) {
            let cafeData = dataManager.getData(at: settingManager.date, name: cafeName)
            
            if (cafeData.isEmpty(mealType: settingManager.suggestedMeal, keywords: settingManager.closedKeywords)) {
                break a
            }
            
            let startTime = cafeOperatingHour[cafeName]!.dayOfTheWeek(date: settingManager.date)!.mealTypeToStartTime(settingManager.suggestedMeal)!
            if (currentHour < 5 || currentHour > endDate.hour) {
                return "식당 영업 종료🌙"
            }
            else if (isRhsBigger(lhs: (currentHour, currentMinute), rhs: startTime)) { //시작시간 전
                return "\(cafeName)에서 \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.suggestedMeal.rawValue)밥 준비중!"
            }
            var newEndDate = Calendar.current.date(bySettingHour: endDate.hour, minute: endDate.minute, second: 0, of: settingManager.date)!
            if (newEndDate < settingManager.date) {
                newEndDate = newEndDate.addingTimeInterval(86400)
            }
            let (hour, minute) = remainTime(from: settingManager.date, to: newEndDate)
            return "\(cafeName) \(settingManager.suggestedMeal.rawValue)마감까지 \(hour)시간 \(minute)분!"
        }
        else {
            if (currentHour < 5 || currentHour > SmartSuggestion.dinnerDefaultTime.0) {
                return "식당 영업 종료🌙"
            }
            else {
                return "\(dayOfTheWeek(of: settingManager.date)) \(settingManager.suggestedMeal.rawValue)에는 운영하지 않아요"
            }
        }
        return "오늘은 운영하지 않아요"
    }
        

    func remainTime(from date1: Date, to date2: Date) -> (hour: String, minute: String) {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date1, to: date2)
        let hours = String(diffComponents.hour!)
        let minutes = String(diffComponents.minute! + 1)
        return (hours, minutes)
    }
}

struct CafeTimerText_Previews: PreviewProvider {
    static var previews: some View {
        TimerText(cafeName: "3식당")
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
