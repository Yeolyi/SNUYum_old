//
//  SimpleTimeBorder.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/20.
//

import Foundation

/// Tuple with hour and minute.
struct SimpleTime: Comparable {
    let hour: Int
    let minute: Int
    
    init(hour: Int, minute: Int = 0) {
        self.hour = hour
        self.minute = minute
    }
    
    init(date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        self.hour = hour
        self.minute = minute
    }
    
    func string() -> String {
        (hour > 12 ? "오후 " : "오전 ") + String(format: "%02d", hour) + ":" + String(format: "%02d", minute)
    }
    
    static func < (left: SimpleTime, right: SimpleTime) -> Bool {
        if left.hour < right.hour {
            return true
        } else if left.hour == right.hour {
            return left.minute < right.minute
        } else {
            return false
        }
    }
}
