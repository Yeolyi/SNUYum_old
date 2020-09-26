//
//  MealTypeSelectView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

enum MealButtonOptions {
    case auto, breakfast, lunch, dinner
}

/// View with buttons to select meal type.
struct MealSelect: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingManager: UserSetting
    let themeColor = ThemeColor()
    
    var body: some View {
        HStack {
            Text("\(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.meal.rawValue) 식단")
                .foregroundColor(.secondary)
                .padding(.leading)
            Spacer()
            HStack {
                MealTypeButton(buttonType: .breakfast)
                MealTypeButton(buttonType: .lunch)
                MealTypeButton(buttonType: .dinner)
                MealTypeButton(buttonType: .auto)
            }
        }
    }
}

/// Single meal type button.
struct MealTypeButton: View {
    
    let buttonType: MealButtonOptions
    let imageName: String
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingManager: UserSetting
    var themeColor = ThemeColor()
    
    /// - Parameter buttonType: Select which meal type this button represents
    init(buttonType: MealButtonOptions) {
        self.buttonType = buttonType
        switch buttonType {
        case .breakfast:
            imageName = "sunrise"
        case .lunch:
            imageName = "sun.max"
        case .dinner:
            imageName = "sunset"
        case.auto:
            imageName = "arrow.clockwise.circle"
        }
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                updateSetting()
            }
        }) {
            ZStack {
                if isSelected() {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 40, height: 40)
                    .foregroundColor(themeColor.title(colorScheme).opacity(0.2))
                    .transition(.scale)
                }
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.clear)
                Image(systemName: imageName)
                    .font(.system(size: 20, weight: .regular))
                    .padding([.leading, .trailing], 1)
                    .foregroundColor(
                        isSelected() ? themeColor.icon((colorScheme)) : Color(.systemFill)
                    )
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func updateSetting() {
        switch buttonType {
        case .auto:
            settingManager.isAuto = true
        case .breakfast:
            settingManager.isAuto = false
            settingManager.mealViewMode = .breakfast
        case .lunch:
            settingManager.isAuto = false
            settingManager.mealViewMode = .lunch
        case .dinner:
            settingManager.isAuto = false
            settingManager.mealViewMode = .dinner
        }
    }
    
    func isSelected() -> Bool {
        if settingManager.isAuto && buttonType == .auto {
            return true
        } else if settingManager.isAuto == false && (
            settingManager.mealViewMode == .breakfast && buttonType == .breakfast ||
            settingManager.mealViewMode == .lunch && buttonType == .lunch ||
            settingManager.mealViewMode == .dinner && buttonType == .dinner ) {
            return true
        } else { return false }
    }
}

struct MealTypeSelectView_Previews: PreviewProvider {
    static var settingManager = UserSetting()
    
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
