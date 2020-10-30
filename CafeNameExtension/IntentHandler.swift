//
//  IntentHandler.swift
//  CafeNameExtension
//
//  Created by Seong Yeol Yi on 2020/10/01.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {
    
    let cafeNameList = [
        "아워홈", "학생회관식당", "자하연식당", "예술계식당", "소담마루", "샤반", "라운지오", "두레미담",
        "동원관식당", "기숙사식당", "공대간이식당", "3식당", "302동식당", "301동식당", "220동식당",
    ]
    
    func resolveCafeName(for intent: ConfigurationIntent, with completion: @escaping (WidgetCafeNameResolutionResult) -> Void) {
        
    }
    
    func provideCafeNameOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<WidgetCafeName>?, Error?) -> Void) {
        var widgetCafeNameList: [WidgetCafeName] = []
        for cafeName in cafeNameList {
            widgetCafeNameList.append(.init(identifier: cafeName, display: cafeName))
        }
        let collection = INObjectCollection(items: widgetCafeNameList)
        completion(collection, nil)
    }
}
