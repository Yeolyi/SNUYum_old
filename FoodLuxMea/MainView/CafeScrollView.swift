//
//  CafeScrollView.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/10/30.
//

import SwiftUI

struct CafeScrollView: View {
    
    @Binding var searchWord: String
    @Binding var selectedCafe: Cafe?
    
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var erasableRowManager: ErasableRowManager
    @EnvironmentObject var listManager: CafeList
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Prevents BlurHeader hides scrollview object.
                Text("")
                    .padding(75)
                SearchBar(searchWord: self.$searchWord)
                if searchWord == "" &&
                    (!erasableRowManager.erasableMessages.isEmpty
                        || settingManager.alimiCafeName != nil || !appStatus.isInternetConnected) {
                    Text("안내")
                        .sectionText()
                }
                if appStatus.isDownloading {
                    HStack {
                        Text("학식 정보 다운로드중...")
                            .accentedText()
                            .foregroundColor(ThemeColor().title(colorScheme))
                        Spacer()
                    }
                    .rowBackground()
                }
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
                    CafeTimer(
                        cafe: dataManager.asyncData.first(where: {$0.name == settingManager.alimiCafeName!})
                            ?? Cafe(name: settingManager.alimiCafeName!),
                        isInMainView: true, selectedCafe: $selectedCafe
                    )
                }
                // Fixed cafe section.
                if self.listManager.fixedList.isEmpty == false {
                    CafeRowsFiltered(isFixed: true, searchWord: self.searchWord, selectedCafe: $selectedCafe)
                }
                // Ordinary cafe section.
                CafeRowsFiltered(isFixed: false, searchWord: self.searchWord, selectedCafe: $selectedCafe)
            }
        }
    }
}
