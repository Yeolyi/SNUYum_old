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
    @State var isSettingSheet = false
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    
    var body: some View {
        // Stacks setting view over main view.
        ZStack {
            // Stacks navigation bar, scrollview and admob.
            VStack {
                // MARK: - Custom navigation bar title and item.
                VStack {
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
                        Button(action: {self.isSettingSheet.toggle()}) {
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
                .resignKeyboardOnDragGesture()
                Divider()
                // Google Admob.
                GADBannerViewController()
                    .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            }
            // MARK: - SettingView covers main view.
            if self.isSettingSheet {
                SettingView(isPresented: self.$isSettingSheet)
                    .zIndex(2) // Priorize setting view to main view
            }
        }
        .alert(isPresented: .constant(!isInternetConnected)) {
            Alert(
                title: Text("인터넷이 연결되지 않았어요"),
                message: Text("저장된 식단은 볼 수 있지만 \n 기능이 제한될 수 있어요"),
                dismissButton: .default(Text("확인"))
            )
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
    }
}
