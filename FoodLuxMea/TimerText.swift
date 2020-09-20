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
  
  init(cafe: Cafe) {
    self.cafe = cafe
  }
  
  var body: some View {
    Button(action: {
      if settingManager.alimiCafeName == cafe.name {
        isTimerSheet = true
      }
    }) {
      HStack {
        Spacer()
        Text(remainingTimeNotice())
          .accentedText()
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
    if let endDate =
        cafeOperatingHour[cafe.name]?.getDaily(
          at: settingManager.date)?.getEndTime(at: settingManager.suggestedMeal) {
      if !cafe.isEmpty(at: [settingManager.suggestedMeal], emptyKeywords: settingManager.closedKeywords) {
        let startTime =
          cafeOperatingHour[cafe.name]!
          .getDaily(at: settingManager.date)!
          .getStartTime(at: settingManager.suggestedMeal)!
        
        if currentHour < 5 || currentHour > endDate.hour {
          return "영업 종료🌙"
        } else if currentSimpleTime < startTime { //시작시간 전
          return
"\(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.suggestedMeal.rawValue)밥 준비중!"
        } else {
          let time = remainTime(from: SimpleTimeBorder(date: Date()), to: endDate)
          return "\(settingManager.suggestedMeal.rawValue) 마감까지 \(time.hour)시간 \(time.minute)분!"
        }
      } else {
        return "\(settingManager.suggestedMeal.rawValue) 메뉴가 없어요."
      }
    }
    // When cafe operating hour data not exists
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
    return dateFormatter.string(from: settingManager.date)
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
