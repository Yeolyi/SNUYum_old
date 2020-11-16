//
//  WidgetCafeteria.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import Foundation
import WidgetKit

class ClippedCafeteria {

    @Published var asyncData: [Cafe] = []

    init() {
        update(at: Date()) { cafeList in
            self.asyncData = cafeList
        }
    }
    
    func clear() {
        SNUCOHandler.clear()
        OurhomeHandler.clear()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static func getCafe(name: String) -> Cafe? {
        let downloaded = try? SNUCOHandler.cafe(date: Date()) + (OurhomeHandler.cafe(date: Date()) != nil ? [OurhomeHandler.cafe(date: Date())!] : [])
        return downloaded?.first(where: {$0.name == name})
    }
    
    /// Get all data of certain date.
    func update(at date: Date, completion: @escaping ([Cafe]) -> Void) {
        asyncData = []
        var downloadedData: [Cafe] = []
        OperationQueue().addOperation {
            print("Cafeteria updating...")
            do {
                downloadedData = try SNUCOHandler.cafe(date: date) + (OurhomeHandler.cafe(date: date) != nil ? [OurhomeHandler.cafe(date: date)!] : [])
                completion(downloadedData)
                DispatchQueue.main.async {
                    self.asyncData = downloadedData
                }
            } catch {
                assertionFailure()
                completion([])
            }
        }
    }
}
