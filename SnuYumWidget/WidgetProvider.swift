//
//  WidgetProvider.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import Foundation
import Intents
import WidgetKit

struct Provider: IntentTimelineProvider {
    
    typealias Entry = SimpleEntry
    
    typealias Intent = ConfigurationIntent
    
    var widgetCafemanager = Cafeteria()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: Intent(), cafe: previewCafe, meal: .lunch)
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let cafeName = configuration.cafeName?.displayString ?? "학생회관식당"
        var proposedDate = Date()
        let dailyProposer = DailyProposer.menu(at: Date(), cafeName: cafeName)
        if dailyProposer.isTomorrow {
            proposedDate = Calendar.current.date(byAdding: .hour, value: 1, to: proposedDate)!
        }
        let cafe = widgetCafemanager.cafe(at: proposedDate, name: cafeName) ?? Cafe(name: cafeName)
        let entry = SimpleEntry(date: Date(), configuration: configuration, cafe: cafe, meal: dailyProposer.meal)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let cafeName = configuration.cafeName?.displayString ?? "학생회관식당"
        var proposedDate = Date()
        let dailyProposer = DailyProposer.menu(at: Date(), cafeName: cafeName)
        if dailyProposer.isTomorrow {
            proposedDate = Calendar.current.date(byAdding: .hour, value: 1, to: proposedDate)!
        }
        let cafe = widgetCafemanager.cafe(at: proposedDate, name: cafeName) ?? Cafe(name: cafeName)
        for _ in 0 ..< 5 {
            let entry = SimpleEntry(date: proposedDate, configuration: configuration, cafe: cafe, meal: dailyProposer.meal)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let configuration: ConfigurationIntent
    var cafe: Cafe
    var meal: MealType
}
