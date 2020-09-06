//
//  FixedCafe.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import Foundation
import CoreData

struct ListElement: Hashable, Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var isFixed: Bool = false
    var isShown: Bool = true
}

class ListManager: ObservableObject{
    
    @Published var cafeList: [ListElement] = []
    
    private var defaultCafeList = ["학생회관식당", "자하연식당", "예술계식당", "두레미담", "동원관식당", "기숙사식당", "공대간이식당", "3식당", "302동식당", "301동식당", "220동식당"]
    
    var fixedList: [ListElement] {
        cafeList.filter {
            $0.isFixed == true
        }
    }
    var unfixedList: [ListElement] {
        cafeList.filter {
            $0.isFixed == false
        }
    }
    
    init() {
        if let loadedData = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea")?.value(forKey: "cafeList") as? Data {
             cafeList = try! PropertyListDecoder().decode([ListElement].self, from: loadedData)
        }
        else {
            for defaultCafeName in defaultCafeList {
                cafeList.append(.init(name: defaultCafeName, isFixed: false, isShown: true))
            }
        }
    }
    
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
            //assertionFailure("ListMananer/toggleFixed: 존재하지 않는 카페값에 접근했습니다.")
            return false
        }
    }
    
    func isFixed(cafeName: String) -> Bool {
        if let index = index(of: cafeName) {
            return cafeList[index].isFixed
        }
        else {
            //assertionFailure("ListMananer/isFixed: 존재하지 않는 카페값에 접근했습니다.")
            return false
        }
    }
}
