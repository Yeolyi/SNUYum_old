//
//  CafeMainRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI


enum filterResult {
    case show
    case closed //자동 숨기기 기능에서 분기가 갈림
    case hide
    case noData
}

struct CafeListFiltered: View {
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    @EnvironmentObject var dataManager: DataManager
    
    @Binding var isCafeView: Bool
    @Binding var activatedCafe: Cafe
    
    let themeColor = ThemeColor()
    let isFixed: Bool
    let searchedText: String
    
    var body: some View {
        let list = isFixed ? listManager.fixedList : listManager.unfixedList
        if let noCafeText = ifEmptyReturnView(list: list) {
            return noCafeText
        }
        return AnyView(
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
                                    .environmentObject(self.themeColor)
                        }
                    }
                         
                    else {
                        EmptyView()
                    }
                }
            }
        )
    }
    
    func nameToCafeRow(_ listElement: ListElement) -> AnyView {
        let cafe = self.dataManager.getData(at: self.settingManager.date, name: listElement.name)
        if searchedText == "" {
             return AnyView(
                Button(action: {self.isCafeView = true; self.activatedCafe = cafe}) {
                    CafeRow(cafe: cafe, suggestedMeal: settingManager.meal)
                                 .modifier(ListRow())
                }
            )
        }
        else {
             return AnyView(
                Button(action: {self.isCafeView = true; self.activatedCafe = cafe}) {
                    SearchCafeRow(cafe: cafe, suggestedMeal: settingManager.meal, searchText: searchedText)
                }
             .padding([.top, .bottom], 5)
             .padding([.leading, .trailing], 10)
            )
        }

    }

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
    
    func listFilter(name: String) -> filterResult {
        let targetCafe = dataManager.getData(at: settingManager.date, name: name)
        if targetCafe.bkfMenuList.isEmpty && targetCafe.lunchMenuList.isEmpty  && targetCafe.dinnerMenuList.isEmpty  {
             return .noData //카페가 cafedata에 존재 안함
        }
        if (searchedText.isEmpty || targetCafe.searchText(searchedText, mealType: settingManager.mealViewMode)) { 
                if (targetCafe.isEmpty(mealType: settingManager.meal, keywords: settingManager.closedKeywords) == false ) {
                    return .show
                }
                else {
                    return .closed
                }
            }
            else { //검색 안됨
                return .hide
            }
    }

}
