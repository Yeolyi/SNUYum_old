//
//  ContentView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/20.
//

import SwiftUI
import GoogleMobileAds
import Network

/// Indicate which type of sheet is shown.
enum sheetEnum: Identifiable {
    // ID to use iOS 14 compatible 'item' syntax in sheet modifier.
    var id: Int {
        self.hashValue
    }
    case cafeView, alimiView
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    @State var searchedText = ""
    @State var isSettingView = false
    @State var isSheet: sheetEnum?
    @State var activatedCafe = previewCafe

    var body: some View {
        GeometryReader{ geo in
            ZStack {
                // SettingView covers main view.
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
                        SearchBar(text: self.$searchedText)
                        // Cafe timer section.
                        if (self.settingManager.alimiCafeName != nil) {
                            Text("안내")
                                .modifier(SectionTextModifier())
                            Button(action: {self.isSheet = .alimiView}) {
                                HStack {
                                    Spacer()
                                    TimerText(cafeName: self.settingManager.alimiCafeName!)
                                    Spacer()
                                }
                                .modifier(ListRow())
                            }
                        }
                        // Fixed cafe section.
                        if (self.listManager.fixedList.isEmpty == false) {
                            Text("고정됨")
                                .modifier(SectionTextModifier())
                            CafeListFiltered(isCafeView: self.$isSheet, activatedCafe: self.$activatedCafe, isFixed: true, searchedText: self.searchedText)
                        }
                        // Ordinary cafe section.
                        Text("식당목록")
                            .modifier(SectionTextModifier())
                        CafeListFiltered(isCafeView: self.$isSheet, activatedCafe: self.$activatedCafe, isFixed: false, searchedText: self.searchedText)
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
            .sheet(item: self.$isSheet) { item in
               if item == .cafeView {
                   CafeView(cafeInfo: self.activatedCafe)
                       .environmentObject(self.dataManager)
                       .environmentObject(self.listManager)
                       .environmentObject(self.settingManager)
               }
               else {
                   CafeView(cafeInfo: self.dataManager.getData(at: self.settingManager.date, name: self.settingManager.alimiCafeName ?? "학생회관식당"))
                       .environmentObject(self.dataManager)
                       .environmentObject(self.listManager)
                       .environmentObject(self.settingManager)
               }
            }
        }
        // TODO: Make theme elements to delete this. 
        .accentColor(themeColor.colorIcon(colorScheme))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataManager = DataManager()
    static var listManager = ListManager()
    static var settingManager = SettingManager()

    static var previews: some View {
        ContentView_Previews.settingManager.update(date: ContentView_Previews.settingManager.date)
        ContentView_Previews.self.listManager.update(newCafeList:ContentView_Previews.self.dataManager.getData(at: ContentView_Previews.self.settingManager.date))
        return ContentView()
            .environmentObject(listManager)
            .environmentObject(dataManager)
            .environmentObject(settingManager)
    }
}
