//
//  SnuYumSmallWidgetEntryView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import WidgetKit
import SwiftUI
import Intents

struct SnuYumSmallWidgetEntryView: View {
    
    private var entry: Provider.Entry

    private var dayOfWeek: String
    private let themeColor = ThemeColor()
    private let menuTrimmed: [Menu]
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
        menuTrimmed = entry.cafe.menus(at: entry.meal).filter { !$0.name.contains("운영") && !$0.name.contains("혼잡") }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
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
                    Spacer()
                }
                HStack {
                    Text(entry.cafe.name)
                        .foregroundColor(themeColor.icon(colorScheme))
                        .widgetTitle()
                        .padding([.leading], 10)
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 7)
            HStack {
                Rectangle()
                    .frame(minWidth: 0, maxWidth: 3, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundColor(themeColor.title(colorScheme))
                    .cornerRadius(2)
                VStack(alignment: .leading) {
                    switch menuTrimmed.count {
                    case 1..<3:
                        ForEach(menuTrimmed) { menu in
                            Text(menu.name)
                                .widgetAccent()
                            if let cost = menu.cost {
                                Text(String(cost) + "원")
                                    .widgetNormal()
                            }
                        }
                    case 3...:
                        ForEach((0..<2), id: \.self) { showableCafeIterate in
                            Text(menuTrimmed[showableCafeIterate].name)
                                .widgetAccent()
                            if let cost = menuTrimmed[showableCafeIterate].cost {
                                Text(String(cost) + "원")
                                    .widgetNormal()
                            }
                        }
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13))
                            .foregroundColor(themeColor.icon(colorScheme))
                            .padding(.top, 1)
                            .padding(.leading, 2)
                    default:
                        Text("메뉴가 없어요")
                            .widgetAccent()
                    }
                }
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.bottom, 10)
            Spacer()
                .frame(minHeight: 5)
        }
    }
    
}

struct SnuYumSmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        SnuYumWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), cafe: previewCafe, meal: .lunch))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
