//
//  FullCafeInfpView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/21.
//

import SwiftUI
import GoogleMobileAds

struct CafeView: View {
    @State var cafeInfo: Cafe
    @State var isMapView = false
    @State var showActionSheet = false

    @EnvironmentObject var cafeList: ListManager
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            List {
                
                Section(header: Text("안내").modifier(SectionTextSmaller())) {
                    TimerText(cafeName: cafeInfo.name)
                }
                
                mealSection(mealType: .breakfast, mealMenus: cafeInfo.bkfMenuList)
                mealSection(mealType: .lunch, mealMenus: cafeInfo.lunchMenuList)
                mealSection(mealType: .dinner, mealMenus: cafeInfo.dinnerMenuList)
                
                Section(header: Text("식당 정보").modifier(SectionTextSmaller())) {
                    Text(cafeDescription[cafeInfo.name] ?? "정보 없음")
                        .font(.system(size: 16))
                        .padding()
                    
                    HStack() {
                        
                        HStack() {
                            Spacer()
                            Image(systemName: "phone")
                                .font(.system(size: 20))
                                .foregroundColor(themeColor.colorTitle(colorScheme))
                            Text("전화 걸기")
                                .font(.system(size: 16))
                                .foregroundColor(themeColor.colorTitle(colorScheme))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let telephone = "tel://02-"
                            let formattedString = telephone + self.cafeInfo.phoneNum
                            guard let url = URL(string: formattedString) else { return }
                            UIApplication.shared.open(url)
                        }
                    
                        Divider()
                        
                        HStack {
                            Spacer()
                            Image(systemName: "map")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(themeColor.colorTitle(colorScheme))
                            Text("위치 보기")
                                .font(.system(size: 16))
                                .foregroundColor(themeColor.colorTitle(colorScheme))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.isMapView = true
                        }
                    }
                }
            }
            GADBannerViewController()
            .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
        }
        .navigationBarTitle(Text(cafeInfo.name))
        .navigationBarItems(trailing:
            HStack {
                Button(action: {
                        let _ = self.cafeList.toggleFixed(cafeName: self.cafeInfo.name)
                        self.cafeList.save()
                }) {
                    Image(systemName: cafeList.isFixed(cafeName: self.cafeInfo.name) ? "pin" : "pin.slash")
                        .font(.system(size: 25, weight: .light))
                        .foregroundColor(themeColor.colorIcon(colorScheme))
                }
            })
        .sheet(isPresented: $isMapView) {
            MapView(cafeInfo: self.cafeInfo)
                .environmentObject(self.themeColor)
        }
    }
    
    func mealSection(mealType: MealType, mealMenus: [Menu]) -> AnyView {
        
        if (mealMenus.isEmpty == false && cafeOperatingHour[cafeInfo.name]?.dayOfTheWeek(date: settingManager.date)?.meal(mealType) != nil) {
            return AnyView(
                Section(header:
                    Text(mealType.rawValue + " (" + (cafeOperatingHour[cafeInfo.name]?.dayOfTheWeek(date: settingManager.date)?.meal(mealType)!)!  + ")")
                        .modifier(SectionTextSmaller())
                ) {
                ForEach(mealMenus) { menu in
                    HStack{
                        Text(menu.name)
                            .modifier(TitleText())
                            .foregroundColor(self.themeColor.colorTitle(self.colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                            .onTapGesture {
                                print(menu.name)
                        }
                        Spacer()
                        Text(self.costInterpret(menu.cost) ?? "")
                            .foregroundColor(Color(.gray))
                    }
                }
            })
        }
        else {
            return AnyView(EmptyView())
        }

        
    }
    
    func costInterpret(_ cost: Int) -> String?{
        if (cost == -1) {
            return nil
        }
        else if ((cost - 10) % 100 == 0) {
            return String(cost - 10) + "원 부터"
        }
        else {
            return String(cost) + "원"
        }
    }
}

struct CafeView_Previews: PreviewProvider {
    static var previews: some View {
        listByVersion(view:
            AnyView(
                NavigationView {
                    CafeView(cafeInfo: previewCafe)
                        .environmentObject(ListManager())
                        .environmentObject(DataManager())
                        .environmentObject(SettingManager())
                }
                )
        )
    }
}
