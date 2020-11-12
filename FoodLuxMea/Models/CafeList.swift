//
//  FixedCafe.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import Foundation
import CoreData

/// Manages how whole cafe data will be displayed.
class CafeList: ObservableObject {
    
    /// ListElement storage.
    @AutoSave("cafeList", defaultValue: [])
    var cafeList: [ListElement] {
        willSet {
            objectWillChange.send()
        }
    }
    
    init() {
        if cafeList == [] {
            clear()
        }
    }
    
    /// Return fixed cafe ListElement array.
    var fixedList: [ListElement] {
        cafeList.filter { $0.isFixed == true }
    }
    /// Return unfixed cafe ListElement array.
    var unfixedList: [ListElement] {
        cafeList.filter { $0.isFixed == false }
    }

    func clear() {
        cafeList = []
        let cafeNameList = [
            "아워홈", "학생회관식당", "자하연식당", "예술계식당", "소담마루", "샤반", "라운지오", "두레미담",
            "동원관식당", "기숙사식당", "공대간이식당", "3식당", "302동식당", "301동식당", "220동식당"
        ]
        for cafeName in cafeNameList {
            cafeList.append(.init(name: cafeName, isFixed: false, isShown: true))
        }
    }
    
    /// Add new 'ListElement' in manager based on new cafe list.
    ///
    /// If cafe data is updated, list data should also be updated.
    func update(newCafeList: [Cafe]) {
        for cafe in newCafeList {
            if (cafeList.contains(where: {$0.name == cafe.name}) == false ) {
                cafeList.append(.init(name: cafe.name))
            }
        }
        print("ListManager Updated")
    }
    
    /// Get specific cafe's index
    func index(of str: String) -> Int? {
        cafeList.firstIndex(where: {$0.name == str})
    }
    
    func toggleFixed(cafeName: String) -> Bool {
        if let index = index(of: cafeName) {
            cafeList[index].isFixed.toggle()
            return true
        } else {
            assertionFailure("ListMananer/toggleFixed: 존재하지 않는 카페값에 접근했습니다.")
            return false
        }
    }
    
    func isFixed(cafeName: String) -> Bool {
        for cafe in cafeList where cafe.name == cafeName {
            return cafe.isFixed
        }
        return false
    }
}
