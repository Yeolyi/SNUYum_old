//
//  ActiveAlert.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/10/30.
//

import Foundation

enum ActiveAlert: Identifiable {
    var id: Int {
        self.hashValue
    }
    case clearCafe, clearAll
}
