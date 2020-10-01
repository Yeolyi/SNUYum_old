//
//  SnuYumWidget.swift
//  SnuYumWidget
//
//  Created by Seong Yeol Yi on 2020/10/01.
//

import WidgetKit
import SwiftUI
import Intents

struct SnuYumMediumWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        Text("중간")
    }
    
}

struct SnuYumSmallWidgetEntryView: View {
    
    var entry: Provider.Entry
    var dayOfWeek: String
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    
    init(entry: SimpleEntry) {
        self.entry = entry
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "EEEE"
        dayOfWeek = dateFormatter.string(from: entry.date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Group {
                        Text("\(dayOfWeek) ")
                            .font(.system(size: CGFloat(15), weight: .semibold, design: .default))
                            .foregroundColor(.secondary)
                        +
                            Text(entry.meal.rawValue)
                        .font(.system(size: CGFloat(15), weight: .bold, design: .default))
                        .foregroundColor(themeColor.icon(colorScheme))
                    }
                    .lineLimit(1)
                    .padding(.leading, 10)
                    Spacer()
                }
                HStack {
                    Text(entry.cafe.name)
                        .font(.system(size: CGFloat(20), weight: .bold, design: .default))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding([.leading], 10)
                        .fixedSize()
                        .lineLimit(1)
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
                    switch entry.cafe.menus(at: entry.meal).count {
                    case 1..<3:
                        ForEach(entry.cafe.menus(at: entry.meal)) { menu in
                            Text(menu.name)
                                .font(.system(size: CGFloat(15), weight: .semibold, design: .default))
                                .foregroundColor(themeColor.title(colorScheme))
                                .fixedSize()
                                .lineLimit(1)
                            if let cost = menu.cost {
                                Text(String(cost) + "원")
                                    .font(.system(size: CGFloat(15), weight: .regular, design: .default))
                                    .foregroundColor(.secondary)
                                    .fixedSize()
                                    .lineLimit(1)
                            }
                        }
                    case 3...:
                        ForEach((0..<2), id: \.self) {
                            Text(entry.cafe.menus(at: entry.meal)[$0].name)
                                .font(.system(size: CGFloat(15), weight: .semibold, design: .default))
                                .foregroundColor(themeColor.title(colorScheme))
                                .fixedSize()
                                .lineLimit(1)
                            if let cost = entry.cafe.menus(at: entry.meal)[$0].cost {
                                Text(String(cost) + "원")
                                    .font(.system(size: CGFloat(15), weight: .regular, design: .default))
                                    .foregroundColor(.secondary)
                                    .fixedSize()
                                    .lineLimit(1)
                            }
                        }
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13))
                            .foregroundColor(themeColor.icon(colorScheme))
                            .padding(.top, 1)
                    default:
                        Text("메뉴가 없습니다")
                            .font(.system(size: CGFloat(15), weight: .semibold, design: .default))
                            .foregroundColor(themeColor.title(colorScheme))
                            .fixedSize()
                            .lineLimit(1)
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

struct SnuYumWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall: SnuYumSmallWidgetEntryView(entry: entry)
        case .systemMedium: SnuYumMediumWidgetEntryView(entry: entry)
        default: SnuYumMediumWidgetEntryView(entry: entry)
        }
    }
}

@main
struct SnuYumWidget: Widget {
    let kind: String = "SnuYumWidget"
    @Environment(\.widgetFamily) var family

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SnuYumWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("스누냠 위젯")
        .description("선택한 식당의 학식을 바로 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}

struct SnuYumWidget_Previews: PreviewProvider {
    static var previews: some View {
        SnuYumWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), cafe: previewCafe, meal: .breakfast))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
