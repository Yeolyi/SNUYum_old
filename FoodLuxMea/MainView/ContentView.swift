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
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()
    @State var searchWord = ""
    @State var isSettingView = false
    @State var isTimerSheet = false

    var body: some View {
        GeometryReader{ geo in
            ZStack {
                // MARK: - SettingView covers main view.
                if (self.isSettingView) {
                    SettingView(isPresented: self.$isSettingView)
                    .zIndex(2)
                }
                // VStack for fixed admob on bottom.
                VStack {
                    VStack {
                        // Custom navigation bar title and item.
                        HStack {
                            VStack(alignment: .leading) {
                                Text("스누냠")
                                    .font(.system(size: CGFloat(18), weight: .bold))
                                    .foregroundColor(.secondary)
                                Text("식단 바로보기")
                                    .font(.system(size: CGFloat(25), weight: .bold))
                            }
                            .padding([.leading, .top])
                            Spacer()
                            Button(action: {self.isSettingView.toggle()}) {
                               Image(systemName: "gear")
                                    .font(.system(size: 25, weight: .regular))
                                    .foregroundColor(themeColor.icon(colorScheme))
                            }
                            .padding()
                            .offset(y: 10)
                        }
                        // Navigation bar meal type select view.
                        Group {
                            MealSelect()
                        }
                        .padding([.trailing, .leading], 10)
                    }
                    Divider()
                    // Cafe row starts here.
                    ScrollView {
                        //Searchbar
                        SearchBar(text: self.$searchWord)
                        // Cafe timer section.
                        if (self.settingManager.alimiCafeName != nil) {
                            Text("안내")
                                .sectionText()
                            Button(action: {isTimerSheet = true}) {
                                HStack {
                                    Spacer()
                                    TimerText(cafeName: self.settingManager.alimiCafeName!)
                                    Spacer()
                                }
                                .listRow()
                            }
                            .sheet(isPresented: $isTimerSheet) {
                                if let cafe = dataManager.cafe(at: settingManager.date, name: settingManager.alimiCafeName!) {
                                    CafeView(cafeInfo: cafe)
                                        .environmentObject(self.listManager)
                                        .environmentObject(self.settingManager)
                                        .environmentObject(self.dataManager)
                                }
                            }
                        }
                        // Fixed cafe section.
                        if (self.listManager.fixedList.isEmpty == false) {
                            Text("고정됨")
                                .sectionText()
                            CafeRowsFiltered(isFixed: true, searchWord: self.searchWord)
                        }
                        // Ordinary cafe section.
                        Text("식당목록")
                            .sectionText()
                        CafeRowsFiltered(isFixed: false, searchWord: self.searchWord)
                    }
                    Divider()
                    // Google Admob.
                    GADBannerViewController()
                    .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                }
            }
            .resignKeyboardOnDragGesture()
            .alert(isPresented: .constant(!isInternetConnected)) {
                        Alert(title: Text("인터넷이 연결되지 않았어요"), message: Text("저장된 식단은 볼 수 있지만 \n 기능이 제한될 수 있어요"), dismissButton: .default(Text("확인")))
                    }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataManager = DataManager()
    static var listManager = ListManager()
    static var settingManager = SettingManager()

    static var previews: some View {
        ContentView_Previews.settingManager.update()
        ContentView_Previews.self.listManager.update(newCafeList:ContentView_Previews.self.dataManager.loadAll(at: ContentView_Previews.self.settingManager.date))
        return ContentView()
            .environmentObject(listManager)
            .environmentObject(dataManager)
            .environmentObject(settingManager)
    }
}
