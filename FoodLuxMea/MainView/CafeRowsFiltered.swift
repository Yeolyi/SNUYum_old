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
    
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var dataManager: Cafeteria
    let themeColor = ThemeColor()
    
    /**
     - Parameters:
     - isFixed: Show fixed cafe only or not
     - searchWord: If something is searched, filters the cafe list
     */
    init(isFixed: Bool, searchWord: String) {
        self.isFixed = isFixed
        self.searchWord = searchWord
    }
    
    var body: some View {
        let list = isFixed ? listManager.fixedList : listManager.unfixedList
        if list.filter(listFilter).isEmpty {
            if isFixed {
                EmptyView()
            } else {
                Text("일반")
                    .sectionText()
                HStack {
                    Spacer()
                    Text(searchWord == "" ? "운영중인 식당이 없어요" : "검색 결과가 없어요")
                    Spacer()
                }
                .rowBackground()
            }
        } else {
            Text(isFixed ? "고정됨" : "일반")
                .sectionText()
            ForEach(list.filter(listFilter)) { listElement in
                CafeRow(
                    cafe: dataManager.asyncData.first(where: {$0.name == listElement.name}) ?? Cafe(name: listElement.name),
                    suggestedMeal: settingManager.meal, searchText: searchWord
                )
            }
        }
    }
    
    /// Evaluate ListElement and return appropriate filter result.
    func listFilter(listElement: ListElement) -> Bool {
        if let targetCafe =  dataManager.asyncData.first(where: {$0.name == listElement.name}) {
            if searchWord == "" {
                if targetCafe.isEmpty(at: [settingManager.meal], emptyKeywords: closedKeywords) {
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
