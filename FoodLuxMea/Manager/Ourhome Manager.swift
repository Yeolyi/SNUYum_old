//
//  Ourhome Manager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/05.
//

import SwiftUI

class OurhomeManager {
    
    func makeURL(from date: Date) -> URL { //DataManager에서 [String:[Cafe]]에 사용
        let targetDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
        let targetURLString = "https://snuco.snu.ac.kr/ko/foodmenu?field_menu_date_value_1%5Bvalue%5D%5Bdate%5D=&field_menu_date_value%5Bvalue%5D%5Bdate%5D=" + String(targetDate.month!) + "%2F" + String(targetDate.day!) + "%2F" + String(targetDate.year!)
        if let targetURL = URL(string: targetURLString) {
            return targetURL
        }
        else{
            assertionFailure("HTMLManager/makeURL(from: ): 문자열을 URL로 변환하는데 실패하였습니다.")
            return URL(string: "https://snuco.snu.ac.kr/ko/foodmenu")!
        }
    }
}
