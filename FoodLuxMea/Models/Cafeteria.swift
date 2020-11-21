//
//  CafeDataManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI
import WidgetKit

/// Retrieves, saves and updates all cafe datas.
class Cafeteria: ObservableObject {
    
    @Published var asyncData: [Cafe] = []
    
    /// Loads existing datas or initializes them into default values.
    init() {
        if appStatus.isFirstVersionRun {
            SNUCOHandler.clear()
            OurhomeHandler.clear()
            print("Version first run: Cafe data eliminated.")
        }
    }
    
    func clear() {
        SNUCOHandler.clear()
        OurhomeHandler.clear()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// Get all data of certain date.
    func update(at date: Date, completion: @escaping ([Cafe]) -> Void) {
        asyncData = []
        var downloadedData: [Cafe] = []
        appStatus.isDownloading = true
        OperationQueue().addOperation {
            print("Cafeteria updating...")
            do {
                downloadedData = try SNUCOHandler.cafe(date: date) + (OurhomeHandler.cafe(date: date) != nil ? [OurhomeHandler.cafe(date: date)!] : [])
                completion(self.asyncData)
                DispatchQueue.main.async {
                    self.asyncData = downloadedData
                    appStatus.isDownloading = false
                }
            } catch {
                print(error.localizedDescription)
                appStatus.isDownloading = false
                completion([])
            }
        }
    }
}
