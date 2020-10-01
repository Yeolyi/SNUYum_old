//
//  SnuYumWidget.swift
//  SnuYumWidget
//
//  Created by Seong Yeol Yi on 2020/10/01.
//

import WidgetKit
import SwiftUI
import Intents

class Cafeteria {
    
    /// Cafe struct storage.
    ///
    /// - Note: Using dictionary with URL key to find stored data efficient.
    private var cafeData: [URL: [Cafe]] = [:]
    /// Downloads snuco cafe datas.
    private var hTMLManager = SNUCODownloader()
    /// Downloads ourhome cafe data.
    private var ourhomeManager = OurhomeStorage()
    
    /**
     Loads existing datas or initializes them into default values.
     
     - Attention: This class should be managed in every version change.
     
     - Important: If data managing algorithm changes, existing data should be deleted and reloaded
     */
    init() {
        if let loadedData =
            UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea")?.value(forKey: "cafeData") as? Data {
            do {
                cafeData = try PropertyListDecoder().decode([URL: [Cafe]].self, from: loadedData)
                print("Widget: DataManager loaded.")
            } catch {
                print("Widget: DataManager load failed.")
            }
        }
    }
    
    func clear() {
        cafeData = [:]
    }
    
    func save() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if let encodedData = try? PropertyListEncoder().encode(cafeData) {
                userDefault.set(encodedData, forKey: "cafeData")
                print("CafeDataManager/save(): cafeData가 저장되었습니다")
            } else {
                print("CafeDataManager/save(): 데이터 인코딩에 실패했습니다.")
            }
        } else {
            print("CafeDataManager/save(): UserDefaults 로딩에 실패했습니다.")
        }
    }
    
    /// Get all data of certain date.
    func loadAll(at date: Date) -> [Cafe] {
        let uRLString = SNUCODownloader.makeURL(from: date)
        if let data = cafeData[uRLString] {
            return data
        } else {
            let newData =
                SNUCODownloader.download(at: date) +
                (ourhomeManager.getCafe(date: date) != nil ? [ourhomeManager.getCafe(date: date)!] : [])
            cafeData[uRLString] = newData
            save()
            return newData
        }
    }
    
    /**
     Get specific cafe data from selected date.
     
     - Remark: If there's no such cafe, returns empty cafe struct with same name.
     */
    func cafe(at date: Date, name: String) -> Cafe? {
        let uRLString = SNUCODownloader.makeURL(from: date)
        if let data = cafeData[uRLString] {
            return data.first { $0.name == name }
        } else {
            let newData = self.loadAll(at: date)
            cafeData[uRLString] = newData
            for cafe in newData where cafe.name == name {
                return cafe
            }
        }
        return nil
    }
}

struct Provider: IntentTimelineProvider {
    
    var widgetCafemanager = Cafeteria()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), cafe: Cafe(name: "미리보기"), meal: .lunch)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, cafe: Cafe(name: "미리보기"), meal: .lunch)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        var proposedDate = Date()
        var cafeName = configuration.cafeName?.displayString ?? "학생회관식당"
        
        
        if DailyProposer.menu(at: Date(), cafeName: cafeName).isTomorrow {
            proposedDate = Calendar.current.date(byAdding: .hour, value: 1, to: proposedDate)!
        }
        var cafe = widgetCafemanager.cafe(at: proposedDate, name: cafeName) ?? Cafe(name: "asdasd")
        for _ in 0 ..< 5 {
            let entry = SimpleEntry(date: proposedDate, configuration: configuration, cafe: cafe, meal: .lunch)
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

struct SnuYumWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text(entry.date, style: .date)
            Text(entry.cafe.name)
            Text(entry.meal.rawValue)
            ForEach(entry.cafe.menus(at: entry.meal)) { menu in
                Text(menu.name)
            }
        }
    }
    
}

@main
struct SnuYumWidget: Widget {
    let kind: String = "SnuYumWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SnuYumWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("스누냠 위젯")
        .description("선택한 식당의 학식을 바로 확인하세요.")
    }
}

struct SnuYumWidget_Previews: PreviewProvider {
    static var previews: some View {
        SnuYumWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), cafe: Cafe(name: "미리보기"), meal: .lunch))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
