//
//  CafeMainRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

/// Return VStack of CafeRows after filtering.
struct CafeRowsFiltered: View {
    
    let isFixed: Bool
    let searchWord: String
    
    @Binding var selectedCafe: Cafe?
    
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var dataManager: Cafeteria
    let themeColor = ThemeColor()
    
    var body: some View {
        let list = isFixed ? listManager.fixedList : listManager.unfixedList
        if list.filter(listFilter).isEmpty {
            if isFixed {
                EmptyView()
            } else {
                HStack {
                    Spacer()
                    Text(searchWord == "" ? "운영중인 식당이 없어요" : "검색 결과가 없어요")
                    Spacer()
                }
                .rowBackground()
            }
        } else {
            ForEach(list.filter(listFilter)) { listElement in
                CafeRow(
                    cafe: dataManager.asyncData.first(where: {$0.name == listElement.name}) ?? Cafe(name: listElement.name),
                    suggestedMeal: settingManager.meal, searchText: searchWord, selectedCafe: $selectedCafe
                )
            }
        }
    }
    
    /// Evaluate ListElement and return appropriate filter result.
    func listFilter(listElement: ListElement) -> Bool {
        if let targetCafe =  dataManager.asyncData.first(where: {$0.name == listElement.name}) {
            if searchWord == "" {
                if targetCafe.isEmpty(at: [settingManager.meal], emptyKeywords: closedKeywords) && !listManager.isFixed(cafeName: listElement.name) {
                    return !settingManager.hideEmptyCafe
                } else {
                    return true
                }
            } else {
                if targetCafe.includes(searchWord, at: [.breakfast, .lunch, .dinner]) {
                    return true
                } else {
                    return false
                }
            }
        }
        return !settingManager.hideEmptyCafe
    }
}
