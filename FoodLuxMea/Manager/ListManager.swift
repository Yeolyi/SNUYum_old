//
//  FixedCafe.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import Foundation
import CoreData

/// About how struct Cafe should shown
struct ListElement: Hashable, Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var isFixed: Bool = false
    var isShown: Bool = true
}

/// Manage ListElements
class ListManager: ObservableObject{
    
    @Published var cafeList: [ListElement] = []
    
    /// Return data about fixed cafe
    var fixedList: [ListElement] {
        cafeList.filter {
            $0.isFixed == true
        }
    }
    /// Return data about unfixed cafe
    var unfixedList: [ListElement] {
        cafeList.filter {
            $0.isFixed == false
        }
    }
    
    /// If stored value exists, get
    init() {
        if let loadedData = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea")?.value(forKey: "cafeList") as? Data {
             cafeList = try! PropertyListDecoder().decode([ListElement].self, from: loadedData)
        }
    }
    
    /// If DataManager get new cafe array, add new cafe in list.
    func update(newCafeList: [Cafe]) {
        if (isInternetConnected) {
            for cafe in newCafeList {
                if (cafeList.contains(where: {$0.name == cafe.name}) == false ) {
                    cafeList.append(.init(name: cafe.name))
                    print("ListManager/update: \(cafe.name)이 추가되었습니다.")
                }
            }
        }
        else {
            print("ListManager/update: 인터넷이 연결되어있지 않습니다.")
        }
    }
    
    func save() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea"){
            if let encodedData = try? PropertyListEncoder().encode(cafeList) {
                userDefault.set(encodedData, forKey: "cafeList")
                print("ListManager/save: cafeList가 저장되었습니다")
            }
            else {
                assertionFailure("ListManager/save: 데이터 인코딩에 실패했습니다.")
            }
        }
        else {
            assertionFailure("CafeListManager/save: UserDefaults 로딩에 실패했습니다.")
        }
    }
    
    /// Get specific cafe's index
    func index(of str: String) -> Int? {
        let value = cafeList.firstIndex(where: {$0.name == str})
        if (value == nil) {
            //assertionFailure("ListMananer/index: 존재하지 않는 카페값에 접근했습니다.")
        }
        return value
    }
    
    func toggleFixed(cafeName: String) -> Bool {
        if let index = index(of: cafeName) {
            cafeList[index].isFixed.toggle()
            return true
        }
        else {
            assertionFailure("ListMananer/toggleFixed: 존재하지 않는 카페값에 접근했습니다.")
            return false
        }
    }
    
    func isFixed(cafeName: String) -> Bool {
        if let index = index(of: cafeName) {
            return cafeList[index].isFixed
        }
        else {
            assertionFailure("ListManager/isFixed: 존재하지 않는 카페값에 접근했습니다.")
            return false
        }
    }
}
