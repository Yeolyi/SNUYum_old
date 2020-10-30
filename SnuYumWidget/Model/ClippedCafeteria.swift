//
//  WidgetCafeteria.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import Foundation
import WidgetKit

class ClippedCafeteria {

    func clear() {
        SNUCOHandler.clear()
        OurhomeHandler.clear()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// Get all data of certain date.
    func loadAll(at date: Date) -> [Cafe] {
        try! SNUCOHandler.cafe(date: date) + (OurhomeHandler.cafe(date: date) != nil ? [OurhomeHandler.cafe(date: date)!] : [])
    }

    /// Get specific cafe data from selected date.
    func cafe(at date: Date, name: String) -> Cafe? {
        loadAll(at: date).first(where: {$0.name == name})
    }
}
