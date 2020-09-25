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
    case clearCafe, clearAll, noNetwork
}

struct ContentView: View {
    
    let themeColor = ThemeColor()
    @State var searchWord = ""
    @State var isSettingSheet = false
    @State var activeAlert: ActiveAlert?
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    @EnvironmentObject var erasableRowManager: ErasableRowManager
    
    var body: some View {
        // Stacks setting view over main view.
        ZStack {
            // Stacks navigation bar, scrollview and admob.
            VStack {
                // MARK: - Custom navigation bar title and item.
                VStack {
                    HStack {
                        customNavigationBar(title: searchWord == "" ? "식단 바로보기" : "식단 검색", subTitle: "스누냠")
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.isSettingSheet.toggle()
                            }
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 25, weight: .regular))
                                .foregroundColor(themeColor.icon(colorScheme))
                        }
                        .padding()
                        .offset(y: 10)
                    }
                    if searchWord == "" {
                        MealSelect()
                            .padding([.trailing, .leading], 10)
                    }
                }
                Divider()
                // MARK: - ScrollView starts here.
                ScrollView {
                    // Searchbar
                    SearchBar(searchWord: self.$searchWord)
                    ErasableRow()
                    // Cafe timer row.
                    if settingManager.alimiCafeName != nil && searchWord == "" {
                        Text("안내(\(settingManager.alimiCafeName!))")
                            .sectionText()
                        if let cafe = dataManager.cafe(
                            at: settingManager.date,
                            name: settingManager.alimiCafeName!
                        ) {
                            CafeTimerButton(of: cafe, isInMainView: true)
                        } else {
                            CafeTimerButton(of: Cafe(name: settingManager.alimiCafeName!), isInMainView: true)
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
                Divider()
                // Google Admob.
                GADBannerViewController()
                    .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            }
            // MARK: - SettingView covers main view.
            if self.isSettingSheet {
                SettingView(isPresented: self.$isSettingSheet, activeAlert: $activeAlert)
                    .zIndex(2) // Priorize setting view to main view
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
            case .noNetwork:
                return Alert(
                    title: Text("인터넷이 연결되지 않았어요"),
                    message: Text("저장된 식단은 볼 수 있지만 \n 기능이 제한될 수 있어요"),
                    dismissButton: .default(Text("확인"))
                )
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
        ContentView_Previews.listManager.update(
            newCafeList:
                ContentView_Previews.dataManager.loadAll(
                    at: ContentView_Previews.self.settingManager.date
                )
        )
        return ContentView()
            .environmentObject(listManager)
            .environmentObject(dataManager)
            .environmentObject(settingManager)
            .environmentObject(ErasableRowManager())
    }
}
