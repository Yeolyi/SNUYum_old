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
    @State var activeAlert: ActiveAlert?
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var erasableRowManager: ErasableRowManager
    @EnvironmentObject var appStatus: AppStatus
    
    var body: some View {
        ZStack {
            BlurHeader(padding: isSettingView ? 20 : 5) {
                VStack(spacing: 0) {
                    HStack {
                        CustomHeader(title: headerTitle, subTitle: "스누냠")
                        Spacer()
                        settingButton()
                            .padding()
                            .offset(y: 10)
                    }
                    if !isSettingView {
                        MealSelect()
                            .padding()
                    }
                }
            }
            .zIndex(1)
            VStack(spacing: 0) {
                if isSettingView {
                    SettingView(isPresented: $isSettingView, activeAlert: $activeAlert)
                } else {
                    CafeScrollView(searchWord: $searchWord, isSettingView: $isSettingView, activeAlert: $activeAlert)
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
        isSettingView ? "설정" : (searchWord == "" ? "식단 바로보기" : "식단 검색")
    }
    
    private func settingButton() -> Button<AnyView> {
        return Button(action: {
            withAnimation {
                self.isSettingView.toggle()
            }
        }) {
            if isSettingView {
                return AnyView(
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                )
            } else {
                return AnyView(
                    Image(systemName: "gear")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundColor(themeColor.icon(colorScheme))
                )
            }
        }
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
                    erasableRowManager.clear()
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
        ContentView_Previews.listManager.update(
            newCafeList:
                ContentView_Previews.dataManager.loadAll(
                    at: ContentView_Previews.self.settingManager.date
                )
        )
        let contentView = ContentView()
            .environmentObject(listManager)
            .environmentObject(dataManager)
            .environmentObject(settingManager)
            .environmentObject(ErasableRowManager())
            .environmentObject(AppStatus())
        return Group {
            contentView
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            contentView
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 Plus"))
            contentView
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        }
    }
}
