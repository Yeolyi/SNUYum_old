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
    
    @State var cafeInfo: Cafe
    @State var isMapView = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var cafeList: ListManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    
    /// - Parameter cafeInfo: Cafe data to show in this view.
    init(cafeInfo: Cafe) {
        self._cafeInfo = State(initialValue: cafeInfo)
    }
    
    var body: some View {
        VStack {
            // MARK: - Custom navigationbar view.
            HStack {
                VStack(alignment: .leading) {
                    Text("식단 자세히 보기")
                        .font(.system(size: CGFloat(18), weight: .bold))
                        .foregroundColor(.secondary)
                    Text(cafeInfo.name)
                        .font(.system(size: CGFloat(25), weight: .bold))
                }
                .padding([.leading, .top])
                Spacer()
                Button(action: {
                    _ = self.cafeList.toggleFixed(cafeName: self.cafeInfo.name)
                }) {
                    Image(systemName: cafeList.isFixed(cafeName: self.cafeInfo.name) ? "pin" : "pin.slash")
                        .font(.system(size: 25, weight: .light))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .offset(y: 10)
                }
                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .light))
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
                CafeTimerButton(of: cafeInfo, isInMainView: false)
                mealSection(mealType: .breakfast, menus: cafeInfo.menus(at: .breakfast))
                mealSection(mealType: .lunch, menus: cafeInfo.menus(at: .lunch))
                mealSection(mealType: .dinner, menus: cafeInfo.menus(at: .dinner))
                // MARK: - Cafe information with phone call and map view.
                Text("식당 정보")
                    .sectionText()
                VStack {
                    Text(cafeDescription[cafeInfo.name] ?? "정보 없음")
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
                            let formattedString = telephone + self.cafeInfo.phoneNum
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
                            self.isMapView = true
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
        .sheet(isPresented: $isMapView) {
            MapView(cafeInfo: self.cafeInfo)
                .environmentObject(self.themeColor)
        }
    }
    
    /**
     Single meal information section.
     
     - Parameters:
     - mealType: Determines which data to show.
     - mealMenus: Data to show.
     */
    func mealSection(mealType: MealType, menus: [Menu]) -> AnyView {
        if menus.isEmpty == false {
            return AnyView(
                VStack {
                    Text(
                        mealType.rawValue + " (" +
                            (cafeOperatingHour[cafeInfo.name]?.daily(at: settingManager.date)?
                                .rawValue(at: mealType) ?? "시간 정보 없음")
                            + ")"
                    )
                    .sectionText()
                    ForEach(menus) { menu in
                        HStack {
                            Text(menu.name)
                                .accentedText()
                                .foregroundColor(self.themeColor.title(self.colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                                .onTapGesture {
                                    print(menu.name)
                                }
                            Spacer()
                            Text(self.costInterpret(menu.cost))
                                .foregroundColor(Color(.gray))
                        }
                        .onTapGesture {
                            print(menu.name)
                        }
                        .rowBackground()
                    }
                }
            )
        } else { return AnyView(EmptyView()) }
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
