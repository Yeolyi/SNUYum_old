//
//  SearchCafeRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/07.
//

import SwiftUI

/// Another type of cafe row when user is searching something.
struct SearchCafeRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    var cafe: Cafe
    var suggestedMeal: MealType
    let searchText: String
    
    /**
    - Parameters:
        - cafe: Cafe struct which this view shows
        - suggestedMeal: Meal type of cafe struct which this view shows
        - searchedText: Tells which text is searched
    */
    init(cafe: Cafe, suggestedMeal: MealType, searchText: String) {
        self.cafe = cafe
        self.suggestedMeal = suggestedMeal
        self.searchText = searchText
    }
    
    var body: some View {
            VStack(alignment: .leading){
                Text(cafe.name)
                    .modifier(TitleText())
                    .foregroundColor(themeColor.colorTitle(colorScheme))
                    .padding(.bottom, 3)
                ForEach(cafe.getMenuList(mealType: suggestedMeal).filter{$0.name.contains(searchText)}) { menu in
                    HStack {
                        self.text(target: menu.name, search: self.searchText)
                            .font(.system(size: 15))
                        Spacer()
                        Text(self.costInterpret(menu.cost))
                            .font(.system(size: 15))
                            .padding(.trailing, 10)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
    }
    
    /// Highlights certain texts which is searched.
    func text(target: String, search: String) -> Text {
        
        var colorSet: Set<Int> = []
        let range: Range<String.Index> = target.range(of: search)!
        let index: Int = target.distance(from: target.startIndex, to: range.lowerBound)
        for i in 0..<searchText.count {
            colorSet.insert(index + i)
        }
        
        var tempView: Text = .init("")
        
        func getView(cnt: Int) -> Text{
            if cnt == target.count {
                return tempView
            }
            tempView = tempView +
                (Text(String(target[target.index(target.startIndex, offsetBy: cnt)]))
                .foregroundColor(colorSet.contains(cnt) ? self.themeColor.colorTitle(self.colorScheme) : Color(.label)))
            return getView(cnt: cnt + 1)
        }
        
        return getView(cnt: 0)
    }
    
    /**
    Interpret cost value to adequate string.
    
    - ToDo: Search appropriate class to place this function.
    */
    func costInterpret(_ cost: Int) -> String{
        if (cost == -1) {
            return ""
        }
        else if ((cost - 10) % 100 == 0) {
            return String(cost - 10) + "원 부터"
        }
        else {
            return String(cost) + "원"
        }
    }
}

struct SearchCafeListRow_Previews: PreviewProvider {
    static var previews: some View {
        SearchCafeRow(cafe: previewCafe, suggestedMeal: .dinner, searchText: "Menu")
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
