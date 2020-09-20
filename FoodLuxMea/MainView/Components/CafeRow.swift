//
//  CafeListRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Single row in main view which shows one meal info
struct CafeRow: View {
  
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject var listManager: ListManager
  @EnvironmentObject var dataManager: DataManager
  @EnvironmentObject var settingManager: SettingManager
  @State var isSheet = false
  let themeColor = ThemeColor()
  var cafe: Cafe
  var suggestedMeal: MealType
  let searchText: String
  
  /**
   - Parameters:
   - cafe: Cafe struct which this view shows.
   - suggestedMeal: Meal type in cafe struct which this view shows.
   */
  init(cafe: Cafe, suggestedMeal: MealType, searchText: String) {
    self.cafe = cafe
    self.suggestedMeal = suggestedMeal
    self.searchText = searchText
  }
  
  var body: some View {
    Button(action: {isSheet = true}) {
      VStack(alignment: .leading) {
        HStack {
          Text(cafe.name)
            .accentedText()
            .foregroundColor(themeColor.title(colorScheme))
            .padding(.bottom, 1.5)
          Spacer()
        }
        Spacer()
        Group {
          if searchText == "" {
            ForEach(cafe.menus(at: suggestedMeal)) { menu in
              HStack {
                Text(menu.name)
                  .font(.system(size: 15))
                  .fixedSize(horizontal: false, vertical: true)
                  .lineLimit(1)
                  .foregroundColor(Color(.label))
                Spacer()
                Text(self.costInterpret(menu.cost))
                  .font(.system(size: 15))
                  .padding(.trailing, 10)
                  .foregroundColor(Color(.secondaryLabel))
              }
            }
          } else {
            VStack {
              if cafe.includes(searchText, at: [.breakfast]) {
                searchResult(at: .breakfast)
              }
              if cafe.includes(searchText, at: [.lunch]) {
                searchResult(at: .lunch)
              }
              if cafe.includes(searchText, at: [.dinner]) {
                searchResult(at: .dinner)
              }
            }
          }
        }
      }
    }
    .sheet(isPresented: $isSheet) {
      CafeView(cafeInfo: cafe)
        .environmentObject(self.listManager)
        .environmentObject(self.settingManager)
        .environmentObject(self.dataManager)
    }
    .rowBackground()
  }
  
  func searchResult(at mealType: MealType) -> AnyView {
    AnyView(
      VStack {
        HStack {
          Text(mealType.rawValue)
            .padding(.top, 0.5)
            .foregroundColor(themeColor.icon(colorScheme))
            .font(.system(size: 14, weight: .semibold))
          Spacer()
        }
        ForEach(cafe.menus(at: mealType).filter { $0.name.contains(searchText) }) { menu in
          HStack {
            self.highlight(text: menu.name, target: self.searchText)
              .font(.system(size: 15))
              .fixedSize(horizontal: false, vertical: true)
              .lineLimit(nil)
            Spacer()
            Text(self.costInterpret(menu.cost))
              .font(.system(size: 15))
              .padding(.trailing, 10)
              .foregroundColor(Color(.secondaryLabel))
          }
        }
      }
    )
  }
  
  func highlight(text: String, target: String) -> Text {
    var colorSet: Set<Int> = []
    if let range = text.range(of: target) {
      let index: Int = text.distance(from: text.startIndex, to: range.lowerBound)
      for i in 0..<searchText.count {
        colorSet.insert(index + i)
      }
      
      var tempView: Text = .init("")
      
      func getView(cnt: Int) -> Text {
        if cnt == text.count {
          return tempView
        }
        tempView = tempView +
          (Text(String(text[text.index(text.startIndex, offsetBy: cnt)]))
            .foregroundColor(colorSet.contains(cnt) ? .primary : .secondary))
        return getView(cnt: cnt + 1)
      }
      
      return getView(cnt: 0)
    } else { return Text(text) }
  }
  
  /**
   Interpret cost value to adequate string.
   
   - ToDo: Search appropriate class to place this function.
   */
  func costInterpret(_ cost: Int) -> String {
    if cost == -1 {
      return ""
    } else if (cost - 10) % 100 == 0 {
      return String(cost - 10) + "원 부터"
    } else {
      return String(cost) + "원"
    }
  }
}

struct CafeListRow_Previews: PreviewProvider {
  static var previews: some View {
    CafeRow(cafe: previewCafe, suggestedMeal: .lunch, searchText: "")
      .environmentObject(ListManager())
      .environmentObject(DataManager())
      .environmentObject(SettingManager())
  }
}
