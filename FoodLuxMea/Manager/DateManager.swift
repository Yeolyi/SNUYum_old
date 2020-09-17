//
//  DateManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/06.
//

import Foundation


/// Convert yyyy/MM/dd HH:mm style string to Date 
func getTrimmedDate(from string: String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let date = formatter.date(from: string)!
    guard let trimmedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) else {
        assertionFailure("")
        return Date()
    }
    return trimmedDate
}


func dateToStr(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "dd/MM/yyyy HH:mm"
    return df.string(from: date)
}

func strToDate(_ str: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.date(from: str)!
}
