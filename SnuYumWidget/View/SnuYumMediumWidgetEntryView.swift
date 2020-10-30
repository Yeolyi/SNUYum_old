//
//  SnuYumMediumWidgetEntryView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import WidgetKit
import SwiftUI
import Intents

struct SnuYumMediumWidgetEntryView: View {
    
    var entry: Provider.Entry
    var dayOfWeek: String
    let themeColor = ThemeColor()
    let endTime: String?
    let menuTrimmed: [Menu]
    @Environment(\.colorScheme) var colorScheme
    
    init(entry: SimpleEntry) {
        self.entry = entry
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "EEEE"
        var targetDate = entry.date
        let proposer = DailyProposer(at: entry.date, cafeName: entry.cafe.name).isTomorrow
        if proposer {
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: entry.date)!
        }
        dayOfWeek = dateFormatter.string(from: targetDate)
        endTime = cafeOperatingHour[entry.cafe.name]?.daily(at: entry.date)?.endTime(at: entry.meal)?.string()
        menuTrimmed = entry.cafe.menus(at: entry.meal).filter { !$0.name.contains("운영") && !$0.name.contains("혼잡") }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Group {
                            Text("\(dayOfWeek) ")
                                .foregroundColor(.secondary)
                                +
                                Text(entry.meal.rawValue)
                                .foregroundColor(themeColor.icon(colorScheme))
                        }
                        .widgetSubtitle()
                        .padding(.leading, 10)
                    }
                    HStack {
                        Text(entry.cafe.name)
                            .foregroundColor(themeColor.icon(colorScheme))
                            .widgetTitle()
                            .padding([.leading], 10)
                    }
                }
                Spacer()
                if let endTime = endTime {
                    Text("\(entry.meal.rawValue)은 " + endTime + "까지에요")
                        .widgetNormal()
                        .padding(.trailing, 20)
                } else {
                    Text("\(entry.meal.rawValue)에 운영하지 않아요")
                        .widgetNormal()
                        .padding(.trailing, 20)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 7)
            HStack {
                Rectangle()
                    .frame(minWidth: 0, maxWidth: 3, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundColor(themeColor.title(colorScheme))
                    .cornerRadius(2)
                switch menuTrimmed.count {
                case 0:
                    Text("메뉴가 없어요")
                        .widgetAccent()
                case 1..<4:
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(menuTrimmed) { menu in
                            HStack {
                                Text(menu.name)
                                    .widgetAccent()
                                if let cost = menu.cost {
                                    Text(String(cost) + "원")
                                        .widgetNormal()
                                }
                            }
                        }
                    }
                default:
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach((0..<3), id: \.self) { i in
                            HStack {
                                Text(menuTrimmed[i].name)
                                    .widgetAccent()
                                if let cost = menuTrimmed[i].cost {
                                    Text(String(cost) + "원")
                                        .widgetNormal()
                                }
                            }
                        }
                    }
                    HStack {
                        Rectangle()
                            .frame(minWidth: 0, maxWidth: 3, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            .foregroundColor(themeColor.title(colorScheme))
                            .cornerRadius(2)
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach((3..<min(menuTrimmed.count, 5)), id: \.self) { i in
                                HStack {
                                    Text(menuTrimmed[i].name)
                                        .widgetAccent()
                                    if let cost = menuTrimmed[i].cost {
                                        Text(String(cost) + "원")
                                            .widgetNormal()
                                    }
                                }
                            }
                            if min(menuTrimmed.count, 5) == 5 {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 13))
                                    .foregroundColor(themeColor.icon(colorScheme))
                                    .padding([.top, .bottom], 7)
                                    .padding(.leading, 2)
                            }
                        }
                    }
                }
                
            }
            .padding(.leading, 10)
            .padding(.trailing, 5)
            Spacer()
                .frame(minHeight: 3)
        }
    }
    
}

struct SnuYumMediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        SnuYumWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), cafe: previewCafe, meal: .lunch))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
