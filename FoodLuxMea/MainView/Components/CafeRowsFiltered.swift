//
//  CafeMainRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

/// Results cafe data can have after filtering.
enum filterResult {
    /// Show cafe data.
    case show
    /// Show cafe data when 'hide empty cafe' option is off.
    case empty
    /// Hide cafe data.
    case hide
}
/**
 Return VStack of CafeRows after filtering.

 **Cafe name in ListManager is converted to cafe struct in Datamanager.**
 */
struct CafeRowsFiltered: View {
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    @EnvironmentObject var dataManager: DataManager
    let themeColor = ThemeColor()
    let isFixed: Bool
    let searchWord: String 
    
    /**
     - Parameters:
        - isCafeView: Binding sheetEnum to tell main view to show cafe sheet or not.
        - activatedCafe: Passes cafe struct to main view.
        - isFixed: Show fixed cafe only or not
        - searchedText: If something is searched, filters the cafe list
     */
    init(isFixed: Bool, searchWord: String) {
        self.isFixed = isFixed
        self.searchWord = searchWord
    }
    
    var body: some View {
        let list = isFixed ? listManager.fixedList : listManager.unfixedList
        var rowNum = 0
        for cafeListElement in list {
            switch (listFilter(name: cafeListElement.name)) {
            case .show:
                rowNum += 1
            case .empty:
                rowNum += settingManager.hideEmptyCafe ? 0 : 1
            default:
                break
            }
        }
        if (rowNum == 0) {
            if (searchWord != "") {
                return AnyView(
                    HStack {
                        Spacer()
                        Text("검색 결과가 없어요")
                        Spacer()
                    }
                    .rowBackground()
                )
            }
            else {
                return AnyView(
                    HStack {
                        Spacer()
                        Text("운영중인 식당이 없어요")
                        Spacer()
                    }
                    .rowBackground()
                )
            }
        }
        else {
            return AnyView(
                VStack(spacing: 0) {
                    ForEach(list, id: \.self) { (listElement: ListElement) in
                        if (self.listFilter(name: listElement.name) == .show ||
                                (self.listFilter(name: listElement.name) == .empty && self.settingManager.hideEmptyCafe == false)) {
                            CafeRow(cafe: self.dataManager.cafe(at: self.settingManager.date, name: listElement.name)!, suggestedMeal: settingManager.meal, searchText: self.searchWord)
                                    .environmentObject(self.listManager)
                                    .environmentObject(self.settingManager)
                                    .environmentObject(self.dataManager)
                        }
                    }
                }
            )
        }
    }
    /**
     Evaluate ListElement and return appropriate filter result.
     */
    func listFilter(name: String) -> filterResult {
        if let targetCafe = dataManager.cafe(at: settingManager.date, name: name) {
            if !searchWord.isEmpty {
                if targetCafe.includes(searchWord, at: [.breakfast, .lunch, .dinner]) {
                    return .show
                }
                else {
                    return .hide
                }
            }
            else if (searchWord.isEmpty || targetCafe.includes(searchWord, at: [settingManager.mealViewMode])) {
                    if (!targetCafe.isEmpty(at: [settingManager.meal], emptyKeywords: settingManager.closedKeywords)) {
                        return .show
                    }
                    else {
                        return .empty
                    }
            }
        }
        return .hide
    }
}
