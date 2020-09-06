//
//  SettingView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/24.
//

import SwiftUI
import GoogleMobileAds

enum ActiveSheet: Identifiable {
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
    
    @State var isSheet = false
    @State var activeSheet: ActiveSheet?
    
    var isCustomDate: Binding<Bool> {
            Binding<Bool>(get: {
                self.settingManager.isCustomDate
            }, set: {
                self.settingManager.isCustomDate = $0
                self.settingManager.update(date: self.debugDate.wrappedValue)
                self.listManager.update(newCafeList: self.dataManager.getData(at: self.settingManager.date))
            })
    }
    
    var debugDate: Binding<Date> {
        Binding<Date>(get: {
            self.settingManager.debugDate
        }, set: {
           self.listManager.update(newCafeList: self.dataManager.getData(at: self.settingManager.date))
            self.settingManager.debugDate = $0
            self.settingManager.update(date: $0)
        })
    }
    
    var isHideBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.settingManager.hideEmptyCafe
            },
            set: {
                self.settingManager.hideEmptyCafe = $0
            })
    }
    
    var body: some View {
        List {
            
            
            Section(header: Text("앱 설정")) {
                HStack {
                    Text("식당 순서 변경")
                    Spacer()
                    if (listManager.fixedList.count != 0) {
                        Text("\(listManager.fixedList.count)개 식당이 고정되었어요")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.gray))
                    }
                    else {
                        Text("고정된 식당이 없어요")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.gray))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.isSheet = true
                    self.activeSheet = .reorder
                }
                HStack {
                    Text("알리미 설정")
                    Spacer()
                    Text(settingManager.alimiCafeName == nil ? "꺼짐" : settingManager.alimiCafeName!)
                        .font(.system(size: 15))
                        .foregroundColor(Color(.gray))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.isSheet = true
                    self.activeSheet = .timer
                }
                iOS1314Toggle(isOn: isHideBinding, label: "정보가 없는 식당 숨기기")
            }
            
            /*
            if #available(iOS 14.0, *) {
                Section(header: Text("위젯 설정")){
                    HStack{
                        Text("표시할 식당 선택하기")
                        Spacer()
                        Text("\(widgetManager.cafeName)/\(settingManager.isWidgetAuto ? "자동" : settingManager.widgetMealViewMode.rawValue + " 고정")")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.gray))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isSheet = true
                        activeSheet = .widget
                    }
                }
            }
 */
            Section(header: Text("고급")) {
                iOS1314Toggle(isOn: isCustomDate, label: "사용자 설정 날짜")
                if (settingManager.isCustomDate) {
                    DatePicker(selection: debugDate, label: { EmptyView() })
                }
            }
            Section(header: Text("정보")) {
                HStack {
                    Text("스누냠 정보")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.isSheet = true
                    self.activeSheet = .info
                }
            }
            
        } //List 끝
            .sheet(isPresented: $isSheet) {
                if self.activeSheet == .reorder {
                ListReorder()
                    .environmentObject(self.listManager)
                    .environmentObject(self.settingManager)
                }
                else if self.activeSheet == .timer {
                TimerSelectView()
                    .environmentObject(self.listManager)
                    .environmentObject(self.settingManager)
                }
                else {
                InfoView()
                    .environmentObject(ThemeColor())
                }
        }
        .navigationBarTitle(Text("설정"))
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(ListManager())
            .environmentObject(DataManager())
            .environmentObject(SettingManager())
    }
}
