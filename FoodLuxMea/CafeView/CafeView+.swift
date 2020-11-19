//
//  FullCafeInfpView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import SwiftUI
import GoogleMobileAds

/// Show single Cafe struct's information.
struct CafeView: View {
    
    @State var cafe: Cafe
    @State var isMapSheet = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var cafeList: CafeList
    @EnvironmentObject var settingManager: UserSetting
    
    let themeColor = ThemeColor()
    
    /// - Parameter cafeInfo: Cafe data to show in this view.
    init(cafeInfo: Cafe) {
        self._cafe = State(initialValue: cafeInfo)
    }
    
    var body: some View {
        ScrollView {
            // Prevents BlurHeader hides scrollview object.
            Text("")
                .padding(45)
            CafeTimer(cafe: cafe)
            MealSection(cafe: cafe, mealType: .breakfast)
            MealSection(cafe: cafe, mealType: .lunch)
            MealSection(cafe: cafe, mealType: .dinner)
            Text("식당 정보")
                .sectionText()
            HStack {
                Spacer()
                Text(cafeDescription[cafe.name] ?? "정보 없음")
                    .font(.system(size: 16))
                    .padding()
                Spacer()
            }
            .rowBackground()
            Text("")
                .padding(43)
        }
        .sheet(isPresented: $isMapSheet) {
            MapView(cafeInfo: self.cafe)
                .environmentObject(self.themeColor)
        }
    }
}

struct CafeView_Previews: PreviewProvider {
    static var dataManager = Cafeteria()
    static var listManager = CafeList()
    static var settingManager = UserSetting()
    
    static var previews: some View {
        
        CafeView_Previews.settingManager.update()
        CafeView_Previews.dataManager.update(at: Date()) {cafeList in
            CafeView_Previews.listManager.update(newCafeList: cafeList)
        }
        
        return CafeView(cafeInfo: previewCafe)
            .environmentObject(self.dataManager)
            .environmentObject(self.listManager)
            .environmentObject(self.settingManager)
    }
}
