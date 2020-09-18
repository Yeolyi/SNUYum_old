//
//  Alami.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI
/**
 Simple text view showing remaining cafe operating hours.
 
 - Bug: Alimi crashed on some circumstances.
 */
struct TimerText: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    @Environment(\.colorScheme) var colorScheme
    
    let themeColor = ThemeColor()
    let cafeName: String
    
    /// - Parameter cafeName: Name of cafe to show timer.
    init(cafeName: String) {
        self.cafeName = cafeName
    }
    
    var body: some View {
        Text(timerString())
            .foregroundColor(themeColor.title(colorScheme))
    }
    
    func timerString() -> String {
        // Get current setting time component.
        let currentHour = Calendar.current.component(.hour, from: settingManager.date)
        let currentMinute = Calendar.current.component(.minute, from: settingManager.date)
        
        if let cafeData = dataManager.cafe(at: settingManager.date, name: cafeName) {
        
            // When cafe operating hour data exists
            a: if let endDate = cafeOperatingHour[cafeName]?.getDaily(at: settingManager.date)?.getEndTime(at: settingManager.suggestedMeal) {
                let startTime = cafeOperatingHour[cafeName]!.getDaily(at: settingManager.date)!.getStartTime(at: settingManager.suggestedMeal)!
                
                if (cafeData.isEmpty(at: [settingManager.suggestedMeal], emptyKeywords: settingManager.closedKeywords)) {
                    break a
                }
                
                if (currentHour < 5 || currentHour > endDate.hour) {
                    return "영업 종료, \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") 식단이에요🌙"
                }
                    
                else if SimpleTimeBorder(currentHour, currentMinute) < startTime { //시작시간 전
                    return "\(cafeName)에서 \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.suggestedMeal.rawValue)밥 준비중!"
                }
                
                var newEndDate = Calendar.current.date(bySettingHour: endDate.hour, minute: endDate.minute, second: 0, of: settingManager.date)!
                if (newEndDate < settingManager.date) {
                    newEndDate = newEndDate.addingTimeInterval(60*60*24)
                }
                let (hour, minute) = remainTime(from: settingManager.date, to: newEndDate)
                return "\(cafeName) \(settingManager.suggestedMeal.rawValue)마감까지 \(hour)시간 \(minute)분!"
            }
                
            // When cafe operating hour data not exists
            if (currentHour < 5 || currentHour > SmartSuggestion.dinnerDefaultTime.hour) {
                return "영업 종료, \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") 식단이에요🌙"
            }
            else {
                return "\(dayOfTheWeek(of: settingManager.date)) \(settingManager.suggestedMeal.rawValue)에는 운영하지 않아요."
            }
        }
        else {
            return cafeName + "은 " + (settingManager.isSuggestedTomorrow ? "내일" : "오늘") + " 운영하지 않아요."
        }
    }
        
    /// Calculate time difference.
    func remainTime(from date1: Date, to date2: Date) -> (hour: String, minute: String) {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date1, to: date2)
        let hours = String(diffComponents.hour!)
        let minutes = String(diffComponents.minute! + 1)
        return (hours, minutes)
    }
    
    /// Return day of the week string from input date
    func dayOfTheWeek(of date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let str = dateFormatter.string(from: date)
        switch (str) {
        case "Saturday":
            return "토요일"
        case "Sunday":
            return "일요일"
        default:
            return "평일"
        }
    }
}

struct CafeTimerText_Previews: PreviewProvider {
    static var previews: some View {
        TimerText(cafeName: "3식당")
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
