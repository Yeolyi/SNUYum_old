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
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    
    @Binding var isPresented: Bool {
        willSet {
            listManager.update(newCafeList: dataManager.loadAll(at: self.settingManager.date))
            settingManager.update()
        }
    }
    @State var activeSheet: ActiveSheet?
    
    /// - Parameter isPresented: Pass main view to show current view or not.
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            // Custom navigaion bar.
            HStack {
                VStack(alignment: .leading) {
                    Text("스누냠")
                        .font(.system(size: CGFloat(18), weight: .bold))
                        .foregroundColor(.secondary)
                    Text("설정")
                        .font(.system(size: CGFloat(25), weight: .bold))
                }
                .padding([.leading, .top])
                Spacer()
                Button(action: { self.isPresented = false }) {
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            Divider()
            
            // List rows
            ScrollView {
                VStack(spacing: 0) {
                    
                    Text("기본 설정")
                        .sectionText()
                    // Basic setting - Cafe reorder.
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.activeSheet = .reorder
                    }
                    .rowBackground()
                    // Basic setting - Cafe timer.
                    HStack {
                        Text("알리미 설정")
                            .font(.system(size: 18))
                        Spacer()
                        Text(settingManager.alimiCafeName ?? "꺼짐")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.activeSheet = .timer
                    }
                    .rowBackground()
                    // Basic setting - Hide empty cafe.
                    SimpleToggle(isOn: $settingManager.hideEmptyCafe, label: "정보가 없는 식당 숨기기")
                        .font(.system(size: 18))
                        .rowBackground()
                    // Advanced setting.
                    Text("고급")
                        .sectionText()
                    // Advanced setting - custom date.
                    SimpleToggle(isOn: $settingManager.isCustomDate, label: "사용자 설정 날짜")
                        .font(.system(size: 18))
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
                    // Info
                    Text("정보")
                        .sectionText()
                    HStack {
                        Text("스누냠 정보")
                            .font(.system(size: 18))
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.activeSheet = .info
                    }
                    .rowBackground()
                }
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
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(isPresented: .constant(true))
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
