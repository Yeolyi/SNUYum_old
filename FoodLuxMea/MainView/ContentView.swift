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
    var body: some View {
        listByVersion(view: AnyView(ContentViewComponent()))
    }
}

struct ContentViewComponent: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()
    
    @State var searchedText = ""
    @State var isSettingSheet = false
    
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    //검색창
                    SearchBar(text: $searchedText)
                    //안내 섹션
                    if (settingManager.alimiCafeName != nil) {
                        Section(header: Text("안내").modifier(SectionText())) {
                                NavigationLink(destination: CafeView(cafeInfo: self.dataManager.getData(at: self.settingManager.date, name: settingManager.alimiCafeName!))) {
                                    TimerText(cafeName: settingManager.alimiCafeName!)
                                        .modifier(CenterModifier())
                                        .modifier(TitleText())
                                        .foregroundColor(themeColor.tempColor(colorScheme))
                                }
                            }
                        }
                    //고정 섹션
                    if (listManager.fixedList.isEmpty == false) {
                        Section(header: Text("고정됨").modifier(SectionText())) {
                            MealSelect()
                            CafeListFiltered(isFixed: true, searchedText: searchedText)
                        }
                    }
                    //식당 목록 섹션
                    Section(header: Text("식당 목록").modifier(SectionText())) {
                        if (listManager.fixedList.isEmpty != false) {
                            MealSelect()
                        }
                        CafeListFiltered(isFixed: false, searchedText: searchedText)
                    }
                }
                .navigationBarTitle(Text("식단 바로보기"))
                .navigationBarItems(trailing:
                                        NavigationLink(destination:
                                        SettingView()
                                            .environmentObject(self.listManager)
                                            .environmentObject(self.dataManager)
                                            .environmentObject(self.settingManager)
                                        ) {
                                            Image(systemName: "gear")
                                                .foregroundColor(themeColor.colorIcon(colorScheme))
                                                .font(.system(size: 25, weight: .regular))
                                        }
                            )
                                
                GADBannerViewController()
                .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            }
        }
        .accentColor(themeColor.colorIcon(colorScheme))
        .resignKeyboardOnDragGesture()
        .alert(isPresented: .constant(!isInternetConnected)) {
                    Alert(title: Text("인터넷이 연결되지 않았어요"), message: Text("저장된 식단은 볼 수 있지만 \n 기능이 제한될 수 있어요"), dismissButton: .default(Text("확인")))
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
