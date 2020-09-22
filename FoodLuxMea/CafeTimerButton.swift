//
//  Alami.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI


/// Shows remaining cafe operating hours.
struct CafeTimerButton: View {
    
    let cafe: Cafe
    /// Determines to show sheet on tap or not.
    let isInMainView: Bool
    @State var isCafeViewSheet = false
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    
    @Environment(\.colorScheme) var colorScheme
    
    init(of cafe: Cafe, isInMainView: Bool) {
        self.cafe = cafe
        self.isInMainView = isInMainView
    }
    
    var body: some View {
        // If view is in mainview, show sheet.
        Button(action: { isCafeViewSheet = isInMainView } ) {
            Text(remainingTimeNotice())
                .accentedText()
                .foregroundColor(themeColor.title(colorScheme))
                .centered()
                .rowBackground()
        }
        .sheet(isPresented: $isCafeViewSheet) {
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
                        "\(settingManager.isSuggestedTomorrow ? "내일" : "오늘")" +
                    " \(settingManager.suggestedMeal.rawValue)밥 준비중!"
                } else {
                    let time = remainTime(from: SimpleTimeBorder(date: settingManager.date), to: endDate)
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
    
    /// Calculate time difference of two arguments.
    func remainTime(from simpleDate1: SimpleTimeBorder, to simpleDate2: SimpleTimeBorder) -> SimpleTimeBorder {
        
        func getDate(from simpleDate: SimpleTimeBorder) -> Date {
            let userCalendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.hour = simpleDate.hour
            dateComponents.minute = simpleDate.minute
            return userCalendar.date(from: dateComponents) ?? settingManager.date
        }
        
        let date1 = getDate(from: simpleDate1)
        let date2 = getDate(from: simpleDate2)
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date1, to: date2)
        return SimpleTimeBorder(diffComponents.hour!, diffComponents.minute!)
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
        CafeTimerButton(of: previewCafe, isInMainView: true)
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
            .environmentObject(ListManager())
    }
}
