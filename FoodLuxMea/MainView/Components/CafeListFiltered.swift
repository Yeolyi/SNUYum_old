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
    case closed
    /// Hide cafe data.
    case hide
    /// There's no data we are looking for.
    case noData
}
/**
 Return VStack of CafeRows after filtering.

 **Cafe name in ListManager is converted to cafe struct in Datamanager.**
 */
struct CafeListFiltered: View {
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    @EnvironmentObject var dataManager: DataManager
    let themeColor = ThemeColor()
    let isFixed: Bool
    let searchedText: String 
    
    /**
     - Parameters:
        - isCafeView: Binding sheetEnum to tell main view to show cafe sheet or not.
        - activatedCafe: Passes cafe struct to main view.
        - isFixed: Show fixed cafe only or not
        - searchedText: If something is searched, filters the cafe list
     */
    init(isFixed: Bool, searchedText: String) {
        self.isFixed = isFixed
        self.searchedText = searchedText
    }
    
    var body: some View {
        let list = isFixed ? listManager.fixedList : listManager.unfixedList
        if let noCafeText = ifEmptyReturnView(list: list) {
            return noCafeText
        }
        return AnyView(
            VStack(spacing: 0) {
                ForEach(list, id: \.self) { (listElement: ListElement) in
                        Group {
                        if (self.listFilter(name: listElement.name) == .show) {
                            self.nameToCafeRow(listElement)
                        }
                            
                        else if (self.listFilter(name: listElement.name) == .closed) {
                            if (self.settingManager.hideEmptyCafe == false) {
                                self.nameToCafeRow(listElement)
                                }
                        }
                               
                        else if (self.listFilter(name: listElement.name) == .noData) {
                            if (self.settingManager.hideEmptyCafe == false) {
                                CafeRow(cafe: self.dataManager.getData(at: self.settingManager.date, name: listElement.name), suggestedMeal: self.settingManager.meal)
                                    .environmentObject(self.listManager)
                                    .environmentObject(self.settingManager)
                                    .environmentObject(self.dataManager)
                                        .environmentObject(self.themeColor)
                                    .listRow()
                            }
                        }
                             
                        else {
                            EmptyView()
                        }
                    }
                }
            }
        )
    }
    ///
    func nameToCafeRow(_ listElement: ListElement) -> AnyView {
        let cafe = self.dataManager.getData(at: self.settingManager.date, name: listElement.name)
        if searchedText == "" {
             return AnyView(
                    CafeRow(cafe: cafe, suggestedMeal: settingManager.meal)
                        .environmentObject(self.listManager)
                        .environmentObject(self.settingManager)
                        .environmentObject(self.dataManager)
                        .listRow()
            )
        }
        else {
             return AnyView(
                    SearchCafeRow(cafe: cafe, suggestedMeal: settingManager.meal, searchText: searchedText)
                        .environmentObject(self.listManager)
                        .environmentObject(self.settingManager)
                        .environmentObject(self.dataManager)
            )
        }

    }
    /**
     Evaluate ListElement and return appropriate filter result.
     
     - ToDo: DataManager.getData is used twice in this function and nameToCafeRow. Optimization required.
     */
    func listFilter(name: String) -> filterResult {
        let targetCafe = dataManager.getData(at: settingManager.date, name: name)
        if targetCafe.bkfMenuList.isEmpty && targetCafe.lunchMenuList.isEmpty  && targetCafe.dinnerMenuList.isEmpty  {
             return .noData
        }
        if (searchedText.isEmpty || targetCafe.search(searchedText, at: settingManager.mealViewMode)) {
                if (targetCafe.isEmpty(mealType: settingManager.meal, keywords: settingManager.closedKeywords) == false ) {
                    return .show
                }
                else {
                    return .closed
                }
            }
        else {
            return .hide
        }
    }
    /// If cafe data is completely empty, return text view.
    func ifEmptyReturnView(list: [ListElement]) -> AnyView? {
       var rowNum = 0
       for cafeListElement in list {
           switch (listFilter(name: cafeListElement.name)) {
           case .show:
               rowNum += 1
           case .closed:
               rowNum += settingManager.hideEmptyCafe ? 0 : 1
           default:
               break
           }
       }
       if (rowNum == 0) {
           if (searchedText != "") {
               return AnyView(Text("검색 결과가 없어요"))
           }
           else {
               return AnyView(Text("운영중인 식당이 없어요"))
           }
       }
        return nil
    }

}
