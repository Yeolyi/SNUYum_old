//
//  CafeListRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Single cafe row in main view.
struct CafeRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    var cafe: Cafe
    var suggestedMeal: MealType

    /**
     - Parameters:
        - cafe: Cafe struct which this view shows.
        - suggestedMeal: Meal type of cafe struct which this view shows.
     */
    init(cafe: Cafe, suggestedMeal: MealType) {
        self.cafe = cafe
        self.suggestedMeal = suggestedMeal
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text(cafe.name)
                .modifier(TitleText())
                .foregroundColor(themeColor.colorTitle(colorScheme))
                .padding(.bottom, 3)
            Spacer()
            ForEach(cafe.getMenuList(mealType: suggestedMeal)) { menu in
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
        }
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

struct CafeListRow_Previews: PreviewProvider {
    static var previews: some View {
        CafeRow(cafe: previewCafe, suggestedMeal: .lunch)
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
