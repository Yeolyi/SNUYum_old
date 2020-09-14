//
//  CafeDataManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Manages overall cafeteria datas
class DataManager: ObservableObject {
    
    private var cafeData: [URL: [Cafe]] = [:]
    private var hTMLManager = HTMLManager()
    private var ourhomeManager = OurhomeManager()
    
    init() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            // If some algorithm changes, existing data should be deleted and reloaded
            if userDefaults.bool(forKey: "1.1firstRun") == false {
                print("DataManager/init: 1.1버전 설치가 처음입니다. 데이터를 삭제합니다. ")
                userDefaults.removeObject(forKey: "cafeData")
                return
            }
        }
        if let loadedData = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea")?.value(forKey: "cafeData") as? Data {
            cafeData = try! PropertyListDecoder().decode([URL:[Cafe]].self, from: loadedData)
            print("CafeDataManager/init(): cafeData가 로드되었습니다")
        }
    }
    
    func save() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea"){
            if let encodedData = try? PropertyListEncoder().encode(cafeData) {
                userDefault.set(encodedData, forKey: "cafeData")
                print("CafeDataManager/save(): cafeData가 저장되었습니다")
            }
            else {
                print("CafeDataManager/save(): 데이터 인코딩에 실패했습니다.")
            }
        }
        else {
            print("CafeDataManager/save(): UserDefaults 로딩에 실패했습니다.")
        }
    }
    
    func getData(at date: Date) -> [Cafe]{
        let uRLString = HTMLManager().makeURL(from: date)
        if let data = cafeData[uRLString] {
            return data
        }
        else {
            if (isInternetConnected) {
                print("CafeDataManager.getData(at: ): 다운로드 중, \(date)")
                let newData = hTMLManager.cafeData(at: date) + [ourhomeManager.getCafe(date: date)]
                cafeData[uRLString] = newData
                save()
                return newData
            }
            else {
                print("CafeDataManager.getData(): 인터넷 연결 안됨 \(date)")
                return []
            }
        }
    }
    
    func getData(at date: Date, name: String) -> Cafe {
        let uRLString = hTMLManager.makeURL(from: date)
        if let data = cafeData[uRLString] {
            return data.first{ $0.name == name }!
        }
        else {
            if isInternetConnected {
                print("CafeDataManager.getData(at: name: ): 다운로드 중, \(uRLString)")
                let newData = self.getData(at: date)
                cafeData[uRLString] = newData
                for cafe in newData {
                    if (cafe.name == name) {
                        return cafe
                    }
                }
            }
            else {
                print("CafeDataManager.getData(at: , name: ): 인터넷 연결 안됨 \(date)")
                return Cafe(name: name, phoneNum: phoneNumList[name] ?? "", bkfMenuList: [], lunchMenuList: [], dinnerMenuList: [])
            }
        }
        return Cafe(name: name, phoneNum: phoneNumList[name] ?? "", bkfMenuList: [], lunchMenuList: [], dinnerMenuList: [])
    }
}
