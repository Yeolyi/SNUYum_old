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
    
    @Binding var isPresented: Bool
    @State var isSheet = false
    @State var activeSheet: ActiveSheet?
    
    var isCustomDate: Binding<Bool> {
            Binding<Bool>(get: {
                self.settingManager.isCustomDate
            }, set: {
                self.settingManager.isCustomDate = $0
                self.settingManager.update(date: self.debugDate.wrappedValue)
                self.listManager.update(newCafeList: self.dataManager.getData(at: self.settingManager.date))
                self.settingManager.save()
            })
    }
    
    var debugDate: Binding<Date> {
        Binding<Date>(get: {
            self.settingManager.debugDate
        }, set: {
           self.listManager.update(newCafeList: self.dataManager.getData(at: self.settingManager.date))
            self.settingManager.debugDate = $0
            self.settingManager.update(date: $0)
            self.settingManager.save()
        })
    }
    
    var isHideBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.settingManager.hideEmptyCafe
            },
            set: {
                self.settingManager.hideEmptyCafe = $0
                self.settingManager.save()
            })
    }
    
    var body: some View {
        VStack {
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
                        .font(.system(size: CGFloat(20), weight: .light))
                        .foregroundColor(themeColor.colorIcon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    Text("앱 설정")
                        .modifier(SectionTextModifier())
                
                HStack {
                    Text("식당 순서 변경")
                        .font(.system(size: 18))
                    Spacer()
                    if (listManager.fixedList.count != 0) {
                        Text("\(listManager.fixedList.count)개 식당이 고정되었어요")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.gray))
                    }
                    else {
                        Text("고정된 식당이 없어요")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.isSheet = true
                    self.activeSheet = .reorder
                }
                .modifier(ListRow())
                
                HStack {
                    Text("알리미 설정")
                    .font(.system(size: 18))
                    Spacer()
                    Text(settingManager.alimiCafeName == nil ? "꺼짐" : settingManager.alimiCafeName!)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.isSheet = true
                    self.activeSheet = .timer
                }
                .modifier(ListRow())
            
                iOS1314Toggle(isOn: isHideBinding, label: "정보가 없는 식당 숨기기")
                    .font(.system(size: 18))
                    .modifier(ListRow())
                
                 Text("고급")
                    .modifier(SectionTextModifier())
                
                iOS1314Toggle(isOn: isCustomDate, label: "사용자 설정 날짜")
                    .font(.system(size: 18))
                    .modifier(ListRow())
                
                if (settingManager.isCustomDate) {
                    DatePicker(selection: debugDate, label: { EmptyView() })
                        .modifier(ListRow())
                }
                
                Text("정보")
                    .modifier(SectionTextModifier())
                
                HStack {
                    Text("스누냠 정보")
                    .font(.system(size: 18))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.isSheet = true
                    self.activeSheet = .info
                }
                .modifier(ListRow())
                
                }
            } //List 끝
        }
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
        .background(Color.white)
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
