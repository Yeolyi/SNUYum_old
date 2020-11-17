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
    
    enum ViewStatus {
        case main, cafe, setting
    } 
    
    let themeColor = ThemeColor()
    @State var searchWord = ""
    @State var isSettingView = false
    @State var activeAlert: ActiveAlert?
    @State var currentCafe: Cafe?
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var appStatus: AppStatus
    
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
                        MealSelect()
                            .padding()
                    }
                }
            }
            .zIndex(1)
            VStack(spacing: 0) {
                if isSettingView {
                    SettingView(isPresented: $isSettingView, activeAlert: $activeAlert)
                } else if let cafe = currentCafe {
                    CafeView(cafeInfo: cafe)
                } else {
                    CafeScrollView(searchWord: $searchWord, selectedCafe: $currentCafe)
                }
                // Google Admob.
                GADBannerViewController()
                    .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            }
        }
        .alert(item: $activeAlert) { item in
            mainAlert(item: item)
        }
    }
    
    private var headerTitle: String {
        if let cafe = currentCafe {
            return cafe.name
        }
        return isSettingView ? "설정" : (searchWord == "" ? "식단 바로보기" : "식단 검색")
    }
    
    private var headerSubTitle: String {
        currentCafe != nil ? "식단 자세히 보기" : "스누냠"
    }
    
    private func settingButton() -> AnyView {
        if currentCafe != nil {
            return AnyView(
                HStack {
                    Button(action: {
                            _ = listManager.toggleFixed(cafeName: currentCafe!.name)
                    }) {
                        Image(systemName: listManager.isFixed(cafeName: currentCafe!.name) ? "pin" : "pin.slash")
                            .font(.system(size: 23, weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                            .padding(.trailing, 10)
                    }
                    Button(action: {
                        withAnimation {
                            currentCafe = nil
                        }
                    }) {
                        Text("닫기")
                            .font(.system(size: CGFloat(20), weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                    }
                })
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
    
    private func mainAlert(item: ActiveAlert) -> Alert {
        switch item {
        case .clearCafe:
            return Alert(
                title: Text("다운로드된 데이터를 삭제합니다"),
                message: Text("사용자 설정은 영향받지 않습니다."),
                primaryButton: .destructive(Text("삭제"), action: { dataManager.clear()}),
                secondaryButton: .cancel()
            )
        case .clearAll:
            return Alert(
                title: Text("앱을 초기 상태로 되돌립니다."),
                primaryButton: .destructive(Text("삭제"), action: {
                    dataManager.clear()
                    settingManager.clear()
                    listManager.clear()
                }
                ),
                secondaryButton: .cancel()
            )
        }
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
