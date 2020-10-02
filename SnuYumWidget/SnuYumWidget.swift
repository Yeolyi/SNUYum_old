//
//  SnuYumWidget.swift
//  SnuYumWidget
//
//  Created by Seong Yeol Yi on 2020/10/01.
//

import WidgetKit
import SwiftUI
import Intents

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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SnuYumWidget_Previews: PreviewProvider {
    static var previews: some View {
        SnuYumWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), cafe: previewCafe, meal: .lunch))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
