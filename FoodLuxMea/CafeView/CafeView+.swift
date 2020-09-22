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
    
    @EnvironmentObject var cafeList: ListManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    
    /// - Parameter cafeInfo: Cafe data to show in this view.
    init(cafeInfo: Cafe) {
        self._cafe = State(initialValue: cafeInfo)
    }
    
    var body: some View {
        VStack {
            // MARK: - Custom navigationbar view.
            HStack {
                VStack(alignment: .leading) {
                    Text("식단 자세히 보기")
                        .font(.system(size: CGFloat(18), weight: .bold))
                        .foregroundColor(.secondary)
                    Text(cafe.name)
                        .font(.system(size: CGFloat(25), weight: .bold))
                }
                .padding([.leading, .top])
                Spacer()
                Button(action: {
                    _ = self.cafeList.toggleFixed(cafeName: self.cafe.name)
                }) {
                    Image(systemName: cafeList.isFixed(cafeName: self.cafe.name) ? "pin" : "pin.slash")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .offset(y: 10)
                }
                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            Divider()
            // MARK: - Various cafe information.
            ScrollView {
                Text("안내")
                    .sectionText()
                CafeTimerButton(of: cafe, isInMainView: false)
                MealSection(cafe: cafe, mealType: .breakfast)
                MealSection(cafe: cafe, mealType: .lunch)
                MealSection(cafe: cafe, mealType: .dinner)
                // MARK: - Cafe information with phone call and map view.
                Text("식당 정보")
                    .sectionText()
                VStack {
                    Text(cafeDescription[cafe.name] ?? "정보 없음")
                        .font(.system(size: 16))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    HStack {
                        // Phone call
                        HStack {
                            Spacer()
                            Image(systemName: "phone")
                                .font(.system(size: 20))
                                .foregroundColor(themeColor.title(colorScheme))
                            Text("전화 걸기")
                                .font(.system(size: 16))
                                .foregroundColor(themeColor.title(colorScheme))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let telephone = "tel://02-"
                            let formattedString = telephone + self.cafe.phoneNum
                            guard let url = URL(string: formattedString) else { return }
                            UIApplication.shared.open(url)
                        }
                        Divider()
                        // Map view.
                        HStack {
                            Spacer()
                            Image(systemName: "map")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(themeColor.title(colorScheme))
                            Text("위치 보기")
                                .font(.system(size: 16))
                                .foregroundColor(themeColor.title(colorScheme))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.isMapSheet = true
                        }
                    }
                }
                .rowBackground()
            }
            // MARK: - Google admob.
            Divider()
            GADBannerViewController()
                .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
        }
        .sheet(isPresented: $isMapSheet) {
            MapView(cafeInfo: self.cafe)
                .environmentObject(self.themeColor)
        }
    }
}

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
    
    @EnvironmentObject var settingManager: SettingManager
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
                        HStack {
                            Text(menu.name)
                                .accentedText()
                                .foregroundColor(self.themeColor.title(self.colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .onTapGesture {
                                    print(menu.name)
                                }
                            Spacer()
                            Text(menu.costInterpret())
                                .foregroundColor(Color(.gray))
                        }
                        .onTapGesture {
                            print(menu.name)
                        }
                        .rowBackground()
                    }
                }
        }
    }
}

struct CafeView_Previews: PreviewProvider {
    static var dataManager = DataManager()
    static var listManager = ListManager()
    static var settingManager = SettingManager()
    
    static var previews: some View {
        
        CafeView_Previews.settingManager.update()
        CafeView_Previews.listManager.update(newCafeList: CafeView_Previews.dataManager.loadAll(at: Date()))
        
        return CafeView(cafeInfo: previewCafe)
            .environmentObject(self.dataManager)
            .environmentObject(self.listManager)
            .environmentObject(self.settingManager)
    }
}
