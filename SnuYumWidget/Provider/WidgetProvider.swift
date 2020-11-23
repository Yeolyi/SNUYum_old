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
    
    func cafe(at date: Date, name: String, completion: @escaping (Cafe?) -> Void) {
        var downloadedData: [Cafe] = []
        do {
            downloadedData = try SNUCOHandler.cafe(date: date) + (OurhomeHandler.cafe(date: date) != nil ? [OurhomeHandler.cafe(date: date)!] : [])
            let cafe = downloadedData.first(where: {$0.name == name})
            completion(cafe)
        } catch {
            assertionFailure()
            completion(nil)
        }
    }
    
    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [Entry] = []
        let cafeName = configuration.cafeName?.displayString ?? "학생회관식당"
        var targetDate = Date()
        if DailyProposer(at: Date(), cafeName: cafeName).isTomorrow {
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }
        cafe(at: targetDate, name: cafeName) { cafe in
            if let cafe = cafe {
                var mealIterate = DailyProposer(at: Date(), cafeName: cafeName).meal
                entries.append(.init(date: Date(), configuration: Intent(), cafe: cafe, meal: mealIterate))
                for _ in 0..<3 {
                    if mealIterate == .dinner {
                        let dinnerEndTime =
                            cafeOperatingHour[cafeName]?.daily(at: targetDate)?.endTime(at: .dinner)
                            ?? DailyProposer.getDefault(meal: .dinner)
                        targetDate = Calendar.current.date(bySettingHour: dinnerEndTime.hour, minute: dinnerEndTime.minute, second: 0, of: targetDate)!
                        mealIterate = MealType.next(meal: mealIterate)
                        entries.append(.init(date: targetDate, configuration: Intent(), cafe: cafe, meal: mealIterate))
                        targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                        continue
                    }
                    
                    let timeline = cafeOperatingHour[cafeName]?.daily(at: targetDate)?.endTime(at: mealIterate) ?? DailyProposer.getDefault(meal: mealIterate)
                    targetDate = Calendar.current.date(bySettingHour: timeline.hour, minute: timeline.minute, second: 0, of: targetDate)!
                    mealIterate = MealType.next(meal: mealIterate)
                    entries.append(.init(date: targetDate, configuration: Intent(), cafe: cafe, meal: mealIterate))
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
}
    
struct SimpleEntry: TimelineEntry {
    var date: Date
    let configuration: ConfigurationIntent
    var cafe: Cafe
    var meal: MealType
}
