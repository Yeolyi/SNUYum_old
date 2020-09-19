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
  
  let cafe: Cafe
  @State var isTimerSheet = false
  
  @EnvironmentObject var listManager: ListManager
  @EnvironmentObject var dataManager: DataManager
  @EnvironmentObject var settingManager: SettingManager
  let themeColor = ThemeColor()
  
  @Environment(\.colorScheme) var colorScheme
  
  /// - Parameter cafeName: Name of cafe to show timer.
  init(cafe: Cafe) {
    self.cafe = cafe
  }
  
  var body: some View {
    Button(action: {
      if settingManager.alimiCafeName == cafe.name {
        isTimerSheet = true
      }
    })
    {
      HStack {
        Spacer()
        Text(remainingTimeNotice())
          .foregroundColor(themeColor.title(colorScheme))
        Spacer()
      }
      .rowBackground()
    }
    .sheet(isPresented: $isTimerSheet) {
      CafeView(cafeInfo: cafe)
        .environmentObject(self.listManager)
        .environmentObject(self.settingManager)
        .environmentObject(self.dataManager)
    }
  }
  
  func remainingTimeNotice() -> String {
    // Get current setting time component.
    let userCalendar = Calendar.current
    let currentHour = userCalendar.component(.hour, from: settingManager.date)
    let currentMinute = userCalendar.component(.minute, from: settingManager.date)
    let currentSimpleTime = SimpleTimeBorder(currentHour, currentMinute)
    
    // When cafe operating hour data exists
    a: if let endDate = cafeOperatingHour[cafe.name]?.getDaily(at: settingManager.date)?.getEndTime(at: settingManager.suggestedMeal) {
      let startTime = cafeOperatingHour[cafe.name]!.getDaily(at: settingManager.date)!.getStartTime(at: settingManager.suggestedMeal)!
      
      if (cafe.isEmpty(at: [settingManager.suggestedMeal], emptyKeywords: settingManager.closedKeywords)) {
        break a
      }
      
      if (currentHour < 5 || currentHour > endDate.hour) {
        return "영업 종료, \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") 식단이에요🌙"
      }
      
      else if currentSimpleTime < startTime { //시작시간 전
        return "\(cafe.name)에서 \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.suggestedMeal.rawValue)밥 준비중!"
      }
    }
    // When cafe operating hour data not exists
    if (currentHour < 5 || currentHour > SmartSuggestion.dinnerDefaultTime.hour) {
      return "영업 종료, \(settingManager.isSuggestedTomorrow ? "내일" : "오늘") 식단이에요🌙"
    }
    else {
      return "\(dayOfTheWeek()) \(settingManager.suggestedMeal.rawValue)에는 운영하지 않아요."
    }
  }
  
  /// Calculate time difference.
  func remainTime(from simpleDate1: SimpleTimeBorder, to simpleDate2: SimpleTimeBorder) -> SimpleTimeBorder {
    var dateComponents = DateComponents()
    let userCalendar = Calendar.current
    dateComponents.hour = simpleDate1.hour
    dateComponents.minute = simpleDate1.minute
    let date1 = userCalendar.date(from: dateComponents) ?? Date()
    dateComponents.hour = simpleDate2.hour
    dateComponents.minute = simpleDate2.minute
    let date2 = userCalendar.date(from: dateComponents) ?? Date()
    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date1, to: date2)
    return SimpleTimeBorder(diffComponents.hour!, diffComponents.minute! + 1)
  }
  
  /// Return day of the week string.
  func dayOfTheWeek() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let str = dateFormatter.string(from: settingManager.date)
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
    TimerText(cafe: previewCafe)
      .environmentObject(DataManager())
      .environmentObject(SettingManager())
      .environmentObject(ListManager())
  }
}
