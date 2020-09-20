//
//  SimpleTimeBorder.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/20.
//

import Foundation

/// Tuple with hour and minute.
struct SimpleTimeBorder {
  let hour: Int
  let minute: Int
  
  init(_ hour: Int, _ minute: Int = 0) {
    self.hour = hour
    self.minute = minute
  }
  
  init(date: Date) {
    let hour = Calendar.current.component(.hour, from: date)
    let minute = Calendar.current.component(.minute, from: date)
    self.hour = hour
    self.minute = minute
  }
  
  static func < (left: SimpleTimeBorder, right: SimpleTimeBorder) -> Bool {
    if left.hour < right.hour {
      return true
    } else if left.hour == right.hour {
      return left.minute < right.minute
    } else {
      return false
    }
  }
}
