//
//  WidgetCafeteria.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/10/02.
//

import Foundation

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
