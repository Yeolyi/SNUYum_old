//
//  CafeScrollView.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/10/30.
//

import SwiftUI

struct CafeScrollView: View {
    
    @Binding var searchWord: String
    @Binding var isSettingView: Bool
    @Binding var activeAlert: ActiveAlert?
    
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var erasableRowManager: ErasableRowManager
    @EnvironmentObject var listManager: CafeList
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Prevents BlurHeader hides scrollview object.
                Text("")
                    .padding(75)
                SearchBar(searchWord: self.$searchWord)
                // Cafe timer row.
                if searchWord == "" &&
                    (!erasableRowManager.erasableMessages.isEmpty
                        || settingManager.alimiCafeName != nil || !appStatus.isInternetConnected) {
                    Text("안내")
                        .sectionText()
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
                        of: dataManager.cafe(at: settingManager.date, name: settingManager.alimiCafeName!)
                            ?? Cafe(name: settingManager.alimiCafeName!),
                        isInMainView: true
                    )
                }
                // Fixed cafe section.
                if self.listManager.fixedList.isEmpty == false {
                    CafeRowsFiltered(isFixed: true, searchWord: self.searchWord)
                }
                // Ordinary cafe section.
                CafeRowsFiltered(isFixed: false, searchWord: self.searchWord)
            }
        }
    }
}
