//
//  CafeMainRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

/// Results cafe data can have after filtering.
enum FilterResult {
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
  
  let isFixed: Bool
  let searchWord: String
  
  @EnvironmentObject var listManager: ListManager
  @EnvironmentObject var settingManager: SettingManager
  @EnvironmentObject var dataManager: DataManager
  let themeColor = ThemeColor()
  
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
      switch listFilter(name: cafeListElement.name) {
      case .show:
        rowNum += 1
      case .empty:
        rowNum += settingManager.hideEmptyCafe ? 0 : 1
      default:
        break
      }
    }
    if rowNum == 0 {
      if isFixed {
        return AnyView(EmptyView())
      } else if searchWord != "" {
        return AnyView(
          VStack {
            Text(isFixed ? "고정됨" : "일반")
              .sectionText()
            HStack {
              Spacer()
              Text("검색 결과가 없어요")
              Spacer()
            }
            .rowBackground()
          }
        )
      } else {
        return AnyView(
          VStack {
            Text(isFixed ? "고정됨" : "일반")
              .sectionText()
            HStack {
              Spacer()
              Text("운영중인 식당이 없어요")
              Spacer()
            }
            .rowBackground()
          }
        )
      }
    } else {
      return AnyView(
        VStack(spacing: 0) {
          Text(isFixed ? "고정됨" : "일반")
            .sectionText()
          ForEach(list, id: \.self) { (listElement: ListElement) in
            switch listFilter(name: listElement.name) {
            case .show:
              let cafe = dataManager.cafe(at: settingManager.date, name: listElement.name)!
              CafeRow(cafe: cafe, suggestedMeal: settingManager.meal, searchText: searchWord)
            case .empty:
              if settingManager.hideEmptyCafe == false {
                if let cafe = dataManager.cafe(at: settingManager.date, name: listElement.name) {
                  // Use data if exists.
                  CafeRow(cafe: cafe, suggestedMeal: settingManager.meal, searchText: searchWord)
                } else {
                  //Use empty Cafe if no data exists.
                  CafeRow(
                    cafe: Cafe(name: listElement.name),
                    suggestedMeal: settingManager.meal,
                    searchText: searchWord
                  )
                }
              } else {
                EmptyView()
              }
            default:
              EmptyView()
            }
          }
        }
      )
    }
  }
  
  /**
   Evaluate ListElement and return appropriate filter result.
   */
  func listFilter(name: String) -> FilterResult {
    if let targetCafe = dataManager.cafe(at: settingManager.date, name: name) {
      if searchWord == "" {
        if targetCafe.isEmpty(at: [settingManager.meal], emptyKeywords: settingManager.closedKeywords) {
          return .empty
        } else {
          return .show
        }
      } else {
        if targetCafe.includes(searchWord, at: [.breakfast, .lunch, .dinner]) {
          return .show
        } else {
          return .hide
        }
      }
    }
    return .empty
  }
}
