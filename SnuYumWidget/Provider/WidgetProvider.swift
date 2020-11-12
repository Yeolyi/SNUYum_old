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
    var widgetCafemanager = ClippedCafeteria()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: Intent(), cafe: previewCafe, meal: .lunch)
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration, cafe: previewCafe,
            meal: DailyProposer(at: Date(), cafeName: configuration.cafeName?.displayString ?? "학생회관식당").meal
        )
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [Entry] = []
        let cafeName = configuration.cafeName?.displayString ?? "학생회관식당"
        var mealIterate = DailyProposer(at: Date(), cafeName: cafeName).meal
        
        var targetDate = Date()
        if DailyProposer(at: Date(), cafeName: cafeName).isTomorrow {
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }
        
        var cafe = widgetCafemanager.asyncData.first {$0.name == cafeName} ?? Cafe(name: cafeName)
        
        entries.append(.init(date: Date(), configuration: Intent(), cafe: cafe, meal: mealIterate))
        print("Widget: Add entries - \(mealIterate.rawValue) at \(Date())")
        
        for _ in 0..<3 {
            if mealIterate == .dinner {
                let dinnerEndTime =
                    cafeOperatingHour[cafeName]?.daily(at: targetDate)?.endTime(at: .dinner)
                    ?? DailyProposer.getDefault(meal: .dinner)
                targetDate = Calendar.current.date(bySettingHour: dinnerEndTime.hour, minute: dinnerEndTime.minute, second: 0, of: targetDate)!
                cafe = widgetCafemanager.asyncData.first {$0.name == cafeName} ?? Cafe(name: cafeName)
                mealIterate = MealType.next(meal: mealIterate)
                entries.append(.init(date: targetDate, configuration: Intent(), cafe: cafe, meal: mealIterate))
                print("Widget: Add entries - \(MealType.next(meal: mealIterate).rawValue) at \(targetDate)")
                targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                continue
            }
            
            let timeline = cafeOperatingHour[cafeName]?.daily(at: targetDate)?.endTime(at: mealIterate) ?? DailyProposer.getDefault(meal: mealIterate)
            targetDate = Calendar.current.date(bySettingHour: timeline.hour, minute: timeline.minute, second: 0, of: targetDate)!
            mealIterate = MealType.next(meal: mealIterate)
            entries.append(.init(date: targetDate, configuration: Intent(), cafe: cafe, meal: mealIterate))
            print("Widget: Add entries - \(MealType.next(meal: mealIterate).rawValue) at \(targetDate)")
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
