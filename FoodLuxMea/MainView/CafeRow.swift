//
//  CafeListRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

struct CafeRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let themeColor = ThemeColor()
    var cafe: Cafe
    var suggestedMeal: MealType
    
    var body: some View {
        NavigationLink(destination: CafeView(cafeInfo: cafe)) {
            VStack(alignment: .leading){
                Text(cafe.name)
                    .modifier(TitleText())
                    .foregroundColor(themeColor.colorTitle(colorScheme))
                    .padding(.bottom, 3)
                ForEach(cafe.getMenuList(MealType: suggestedMeal)) { menu in
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
        .contentShape(Rectangle())
    }

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
