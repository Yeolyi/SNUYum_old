//
//  SettingView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/24.
//

import SwiftUI
import GoogleMobileAds

/// Indicate which type of setting sheet is shown.
enum ActiveSheet: Identifiable {
    // ID to use iOS 14 compatible 'item' syntax in sheet modifier.
    var id: Int {
        self.hashValue
    }
    case reorder, timer, info
}

struct SettingView: View {
    
    @Binding var isPresented: Bool {
        willSet {
            listManager.update(newCafeList: dataManager.loadAll(at: self.settingManager.date))
            settingManager.update()
        }
    }
    @State var activeSheet: ActiveSheet?
    @Binding var activeAlert: ActiveAlert?
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var dataManager: Cafeteria
    @EnvironmentObject var settingManager: UserSetting
    let themeColor = ThemeColor()
    
    /// - Parameter isPresented: Pass main view to show current view or not.
    init(isPresented: Binding<Bool>, activeAlert: Binding<ActiveAlert?>) {
        self._isPresented = isPresented
        self._activeAlert = activeAlert
    }
    
    var body: some View {
            // List rows
            Text("")
                .padding(35)
            Group {
                Text("기본 설정")
                    .sectionText()
                // Basic setting - Cafe reorder.
                Button(action: { self.activeSheet = .reorder }) {
                    HStack {
                        Text("식당 순서 변경")
                            .font(.system(size: 18))
                        Spacer()
                        if listManager.fixedList.count != 0 {
                            Text("\(listManager.fixedList.count)개 식당이 고정되었어요")
                                .font(.system(size: 16))
                                .foregroundColor(Color(.gray))
                        } else {
                            Text("고정된 식당이 없어요")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                    .rowBackground()
                }
                .accentColor(themeColor.title(colorScheme))
                // Basic setting - Cafe timer.
                Button(action: { self.activeSheet = .timer }) {
                    HStack {
                        Text("알리미 설정")
                            .font(.system(size: 18))
                        Spacer()
                        Text(settingManager.alimiCafeName ?? "꺼짐")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .rowBackground()
                }
                .accentColor(themeColor.title(colorScheme))
            }
            // Basic setting - Hide empty cafe.
            SimpleToggle(isOn: $settingManager.hideEmptyCafe, label: "정보가 없는 식당 숨기기")
                .rowBackground()
            // Advanced setting.
            Text("고급")
                .sectionText()
            // Advanced setting - custom date.
            SimpleToggle(isOn: $settingManager.isCustomDate, label: "사용자 설정 날짜")
                .rowBackground()
            if settingManager.isCustomDate {
                Text("참고: 이 설정은 저장되지 않습니다.")
                    .foregroundColor(.secondary)
                    .centered()
                    .rowBackground()
                DatePicker(selection: $settingManager.debugDate, label: { EmptyView() })
                    .rowBackground()
                    .accentColor(themeColor.title(colorScheme))
            }
            Button(action: { activeAlert = ActiveAlert.clearCafe }) {
                HStack {
                    Text("저장된 식단 삭제")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .rowBackground()
            }
            Button(action: { activeAlert = ActiveAlert.clearAll }) {
                HStack {
                    Text("전체 초기화")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .rowBackground()
            }
            // Info
            Text("정보")
                .sectionText()
            Button(action: { activeSheet = ActiveSheet.info }) {
                HStack {
                    Text("스누냠 정보")
                        .foregroundColor(themeColor.title(colorScheme))
                        .font(.system(size: 18))
                    Spacer()
                }
            }
            .rowBackground()
        .background(colorScheme == .dark ? Color.black : Color.white)
        // Caution: Sheet modifier position matters.
        .sheet(item: self.$activeSheet) { item in
            switch item {
            case .reorder:
                ListOrderSettingView(cafeListBackup: self.listManager.cafeList)
                    .environmentObject(self.listManager)
                    .environmentObject(self.settingManager)
            case .timer:
                TimerCafeSettingView()
                    .environmentObject(self.listManager)
                    .environmentObject(self.settingManager)
            case .info:
                AboutAppView()
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(isPresented: .constant(true), activeAlert: .constant(.none))
            .environmentObject(CafeList())
            .environmentObject(Cafeteria())
            .environmentObject(UserSetting())
    }
}
