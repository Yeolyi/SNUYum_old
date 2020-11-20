//
//  RatedMenuInfo.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/20.
//

import Foundation

struct RatedMenuInfo {
    let date: String
    let cafeName: String
    let menuName: String
    init(at date: Date, cafe cafeName: String, menu menuName: String) {
        self.cafeName = cafeName
        self.menuName = menuName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date = dateFormatter.string(from: date)
    }
}
