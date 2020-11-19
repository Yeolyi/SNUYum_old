//
//  MealSection.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/26.
//

import SwiftUI

/**
 Single meal information section.
 
 - Parameters:
 - mealType: Determines which data to show.
 - mealMenus: Data to show.
 */
struct MealSection: View {
    
    let cafe: Cafe
    let mealType: MealType
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingManager: UserSetting
    let themeColor = ThemeColor()
    
    var body: some View {
        if cafe.menus(at: mealType).isEmpty == false {
            VStack {
                Text(
                    mealType.rawValue + " (" +
                        (cafeOperatingHour[cafe.name]?.daily(at: settingManager.date)?
                            .rawValue(at: mealType) ?? "시간 정보 없음")
                        + ")"
                )
                .sectionText()
                ForEach(cafe.menus(at: mealType)) { menu in
                    VStack {
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text(menu.name)
                                    .accentedText()
                                    .foregroundColor(self.themeColor.title(self.colorScheme))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                Text(menu.costStr)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(.gray))
                            }
                        }
                    }
                    .rowBackground()
                }
            }
        }
    }
}
