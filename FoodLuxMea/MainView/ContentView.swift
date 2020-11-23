//
//  ContentView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import GoogleMobileAds
import Network

struct ContentView: View {
    
    let themeColor = ThemeColor()
    @State var searchWord = ""
    @State var isSettingView = false
    @State var currentCafe: Cafe?
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    
    var body: some View {
        ZStack {
            BlurHeader(padding: isSettingView || currentCafe != nil ? 20 : 5) {
                VStack(spacing: 0) {
                    HStack {
                        CustomHeader(title: headerTitle, subTitle: headerSubTitle)
                        Spacer()
                        settingButton()
                            .padding()
                            .offset(y: 10)
                    }
                    if !isSettingView && currentCafe == nil {
                        if settingManager.showMealSelectView {
                            MealSelect()
                                .padding()
                        }
                        Button(action: {
                            withAnimation {
                                settingManager.showMealSelectView.toggle()
                            }
                        }) {
                            Image(systemName: settingManager.showMealSelectView ? "chevron.compact.up" : "chevron.compact.down")
                                .font(.system(size: 30, weight: .regular))
                                .foregroundColor(themeColor.icon(colorScheme))
                                .padding([.leading, .trailing], 6)
                                .padding(.top, 8)
                                .padding(.bottom, 2)
                        }
                    }
                }
            }
            .zIndex(1)
            VStack(spacing: 0) {
                if isSettingView {
                    SettingView(isPresented: $isSettingView)
                } else if let cafe = currentCafe {
                    CafeView(cafeInfo: cafe)
                } else {
                    CafeScrollView(searchWord: $searchWord, selectedCafe: $currentCafe)
                }
               
            }
            // Google Admob.
            VStack {
                Spacer()
                GADBannerViewController()
                    .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                if currentCafe != nil {
                    BottomBar(currentCafe: $currentCafe)
                }
            }
            .zIndex(2)
        }
    }
    
    private var headerTitle: String {
        if let cafe = currentCafe {
            return cafe.name
        }
        if isSettingView {
            return "설정"
        } else if searchWord != "" {
            return "식단 검색"
        } else {
            return "\(settingManager.isSuggestedTomorrow ? "내일" : "오늘") \(settingManager.meal.rawValue) 식단"
        }
    }
    
    private var headerSubTitle: String {
        currentCafe != nil ? "식단 자세히 보기" : "스누냠"
    }
    
    private func settingButton() -> AnyView {
        if currentCafe != nil {
            return AnyView(EmptyView())
        }
        return AnyView(
            Button(action: {
                if isSettingView == true {
                    dataManager.update(at: settingManager.date) { cafeList in
                        listManager.update(newCafeList: cafeList)
                    }
                }
                withAnimation {
                    self.isSettingView.toggle()
                }
            }) {
                if isSettingView {
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                } else {
                    Image(systemName: "gear")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundColor(themeColor.icon(colorScheme))
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataManager = Cafeteria()
    static var listManager = CafeList()
    static var settingManager = UserSetting()
    
    static var previews: some View {
        ContentView_Previews.settingManager.update()
        ContentView_Previews.dataManager.update(at: ContentView_Previews.settingManager.date) { cafeList in
            ContentView_Previews.listManager.update(newCafeList: cafeList)
        }
        return ContentView()
            .environmentObject(listManager)
            .environmentObject(dataManager)
            .environmentObject(settingManager)
            .environmentObject(AppStatus())
        
    }
}
