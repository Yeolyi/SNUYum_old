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
        SimpleEntry(date: Date(), configuration: Intent(), cafe: previewCafe, meal: DailyProposer.menu(at: Date(), cafeName: "학생회관식당").meal)
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), configuration: Intent(), cafe: previewCafe, meal: DailyProposer.menu(at: Date(), cafeName: "학생회관식당").meal)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        print("New timeline starts")
        var entries: [Entry] = []
        let cafeName = configuration.cafeName?.displayString ?? "학생회관식당"
        let proposer = DailyProposer.menu(at: Date(), cafeName: cafeName)
        
        var mealIterate = proposer.meal
        var targetDate = Date()
        
        if proposer.isTomorrow {
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }
        
        var cafe = widgetCafemanager.cafe(at: targetDate, name: cafeName) ?? Cafe(name: cafeName)
        
        entries.append(.init(date: Date(), configuration: Intent(), cafe: cafe, meal: proposer.meal))
        print("Widget: Add entries - \(proposer.meal.rawValue) at \(Date())")
        
        for _ in 0..<3 {
            if mealIterate == .dinner {
                let timeline = cafeOperatingHour[cafeName]?.daily(at: targetDate)?.endTime(at: mealIterate) ?? DailyProposer.getDefault(meal: mealIterate)
                targetDate = Calendar.current.date(bySettingHour: timeline.hour, minute: timeline.minute, second: 0, of: targetDate)!
                cafe = widgetCafemanager.cafe(at: targetDate, name: cafeName) ?? Cafe(name: cafeName)
                entries.append(.init(date: targetDate, configuration: Intent(), cafe: cafe, meal: MealType.next(meal: mealIterate)))
                print("Widget: Add entries - \(MealType.next(meal: mealIterate).rawValue) at \(targetDate)")
                targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                mealIterate = MealType.next(meal: mealIterate)
                continue
            }
            let timeline = cafeOperatingHour[cafeName]?.daily(at: targetDate)?.endTime(at: mealIterate) ?? DailyProposer.getDefault(meal: mealIterate)
            targetDate = Calendar.current.date(bySettingHour: timeline.hour, minute: timeline.minute, second: 0, of: targetDate)!
            entries.append(.init(date: targetDate, configuration: Intent(), cafe: cafe, meal: MealType.next(meal: mealIterate)))
            print("Widget: Add entries - \(MealType.next(meal: mealIterate).rawValue) at \(targetDate)")
            mealIterate = MealType.next(meal: mealIterate)
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
