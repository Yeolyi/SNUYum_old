//
//  ContentView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import GoogleMobileAds
import Network

enum ActiveAlert: Identifiable {
    var id: Int {
        self.hashValue
    }
    case clearCafe, clearAll
}

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
            // MARK: - Custom navigation bar title and item.
            BlurHeader(
                headerBottomHeading: isSettingView ? 20 : 5,
                headerView:
                    AnyView(
                        VStack(spacing: 0) {
                            HStack {
                                CustomHeader(title: isSettingView ? "설정" : (searchWord == "" ? "식단 바로보기" : "식단 검색"), subTitle: "스누냠")
                                Spacer()
                                Button(action: {
                                    if isSettingView {
                                        listManager.update(newCafeList: dataManager.loadAll(at: self.settingManager.date))
                                        settingManager.update()
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
                                            .font(.system(size: 30, weight: .regular))
                                            .foregroundColor(themeColor.icon(colorScheme))
                                    }
                                }
                                .padding()
                                .offset(y: 10)
                            }
                            if !isSettingView {
                                MealSelect()
                                    .padding()
                            }
                        }
                    )
            ) {
                VStack(spacing: 0) {
                // MARK: - ScrollView starts here
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if isSettingView {
                                SettingView(isPresented: $isSettingView, activeAlert: $activeAlert)
                            } else {
                                Text("")
                                    .padding(75)
                                // Searchbar
                                SearchBar(searchWord: self.$searchWord)
                                // Cafe timer row.
                                if searchWord == "" && (!erasableRowManager.erasableMessages.isEmpty || settingManager.alimiCafeName != nil || !appStatus.isInternetConnected) {
                                    Text("안내")
                                        .sectionText()
                                    if !appStatus.isInternetConnected {
                                        HStack {
                                            Text("인터넷 연결 안됨")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                            .rowBackground()
                                    }
                                    if !erasableRowManager.erasableMessages.isEmpty {
                                        ErasableRow()
                                    }
                                    if settingManager.alimiCafeName != nil {
                                        if let cafe = dataManager.cafe(
                                            at: settingManager.date,
                                            name: settingManager.alimiCafeName!
                                        ) {
                                            CafeTimer(of: cafe, isInMainView: true)
                                        } else {
                                            CafeTimer(of: Cafe(name: settingManager.alimiCafeName!), isInMainView: true)
                                        }
                                    }
                                }
                                // Fixed cafe section.
                                if self.listManager.fixedList.isEmpty == false {
                                    CafeRowsFiltered(isFixed: true, searchWord: self.searchWord)
                                }
                                // Ordinary cafe section.
                                CafeRowsFiltered(isFixed: false, searchWord: self.searchWord)
                                // Scroll view ends here.
                            }
                        }
                    }
                    Divider()
                    // Google Admob.
                    GADBannerViewController()
                        .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                }
            }

        .alert(item: $activeAlert) { item in
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
