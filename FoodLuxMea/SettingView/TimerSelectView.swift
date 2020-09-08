//
//  CafeTimerSelectView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/29.
//

import SwiftUI

struct TimerSelectView: View {
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    var body: some View {
        listByVersion(view: AnyView(
            TimerSelectViewContent()
            )
        )
    }
}
    
struct TimerSelectViewContent: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    
    let themeColor = ThemeColor()
    
    @State var selectedCafeName: String? = nil
    @State var tempIsTimerCafe: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TitleView(title: "알리미 설정", subTitle: "설정")
                Button(action: {
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("취소")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.colorIcon(colorScheme))
                        .offset(y: 10)
                }
                Button(action: {
                        self.settingManager.alimiCafeName = self.tempIsTimerCafe ? self.selectedCafeName : nil
                        self.settingManager.update(date: self.settingManager.date)
                        self.settingManager.save()
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("저장")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.colorIcon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            
            Divider()
            
            ScrollView {
                
                VStack(spacing: 0) {
                Text("""
식당 사정에 따라 조금 일찍/늦게 끝날 수도 있습니다.
학생회관식당: 1층 기준
자하연 식당: 2층(학생식당) 기준
3식당: 4층 기준
301동 식당: 지하 기준
""")
                    .modifier(ListRow())
                Text("설정")
                    .modifier(SectionTextModifier())
                
                iOS1314Toggle(isOn: $tempIsTimerCafe, label: "알리미 켜기")
                    .modifier(ListRow())
                
                if (tempIsTimerCafe) {
                    Text("목록")
                        .modifier(SectionTextModifier())
                        ForEach(listManager.cafeList) { listElement in
                            Button(action: {self.selectedCafeName = listElement.name}) {
                                HStack {
                                    Spacer()
                                    Text(listElement.name)
                                    Spacer()
                                }
                                .modifier(ListRow())
                                .foregroundColor(self.getColor(cafeName: listElement.name))
                            }
                        }
                }
                
            }
            }
        }
        .onAppear(perform: {
            self.tempIsTimerCafe = self.settingManager.alimiCafeName != nil
            self.selectedCafeName = self.settingManager.alimiCafeName
        })
    }

    func getColor(cafeName: String) -> Color{
        if (cafeName == settingManager.alimiCafeName) {
            return themeColor.colorIcon(colorScheme)
        }
        else if (cafeName == self.selectedCafeName) {
            return Color(.systemGray)
        }
        else {
            return Color(.systemFill)
        }
    }
    
    
}



struct TimerSelectView_Previews: PreviewProvider {
    static var previews: some View {
        TimerSelectView()
            .environmentObject(ListManager())
            .environmentObject(SettingManager())
    }
}
