//
//  MealTypeSelectView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

struct MealSelect: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()

    var body: some View {
        HStack {
            Text("\(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.meal.rawValue) 식단이에요")
                .foregroundColor(.secondary)
                .padding(.leading)
            Spacer()
            HStack {
                Group {
                    MealTypeButton(imageName: "sunrise", buttonType: .breakfast)
                    MealTypeButton(imageName: "sun.max", buttonType: .lunch)
                    MealTypeButton(imageName: "sunset", buttonType: .dinner)
                    ZStack {
                       RoundedRectangle(cornerRadius: 10)
                           .frame(width: 40, height: 40)
                           .foregroundColor(settingManager.isAuto == true ? themeColor.colorTitle(colorScheme) : Color.clear)
                           .opacity(0.2)
                        Button(action: {self.settingManager.isAuto = true; self.settingManager.save()}) {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.system(size: 20, weight: .regular))
                                .padding([.leading, .trailing], 2)
                                .foregroundColor(settingManager.isAuto == true ? themeColor.colorIcon((colorScheme)) : Color(.systemFill))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .modifier(ListRow())
        }

    }
}

struct MealTypeButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingManager: SettingManager
    
    var themeColor = ThemeColor()
    let imageName: String
    @State var buttonType: MealType
    
    var body: some View {
        Button(action: {self.settingManager.mealViewMode = self.buttonType; self.settingManager.isAuto = false; self.settingManager.save()}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40, height: 40)
                        .foregroundColor(settingManager.mealViewMode == buttonType && settingManager.isAuto == false ? themeColor.colorTitle(colorScheme) : Color.clear)
                        .opacity(0.2)
                    Image(systemName: imageName)
                        .font(.system(size: 20, weight: .regular))
                        .padding([.leading, .trailing], 2)
                        .foregroundColor(settingManager.mealViewMode == buttonType && settingManager.isAuto == false ? themeColor.colorIcon((colorScheme)) : Color(.systemFill))
                }
            }
            .buttonStyle(BorderlessButtonStyle())
    }
}

struct MealTypeSelectView_Previews: PreviewProvider {
    static var settingManager = SettingManager()
    
    static var previews: some View {
        settingManager.mealViewMode = .lunch
        settingManager.isAuto = false
        return (
            MealSelect()
                .environmentObject(ThemeColor())
                .environmentObject(settingManager)
        )
    }
}
