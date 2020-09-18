//
//  CafeTimerSelectView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/29.
//

import SwiftUI

/// Select which cafe to show in main view's timer.
struct TimerCafeSettingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject var settingManager: SettingManager
    let themeColor = ThemeColor()
    
    @State var selectedCafeName: String?
    @State var tempIsTimerCafe = false
    let timerGuide = """
식당 사정에 따라 조금 일찍/늦게 끝날 수도 있습니다.
학생회관식당: 1층 기준
자하연 식당: 2층(학생식당) 기준
3식당: 4층 기준
301동 식당: 지하 기준
"""
    
    var body: some View {
        VStack {
            // MARK: - Custom Navigation bar.
            HStack {
                CustomNavigationBar(title: "알리미 설정", subTitle: "설정")
                Button(action: {
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("취소")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .offset(y: 10)
                }
                Button(action: {
                        self.settingManager.alimiCafeName = self.tempIsTimerCafe ? self.selectedCafeName : nil
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("저장")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                Text(timerGuide)
                    .rowBackground()
                Text("설정")
                    .sectionText()
                SimpleToggle(isOn: $tempIsTimerCafe, label: "알리미 켜기")
                    .rowBackground()
                // MARK: - Selectable cafe list.
                if (tempIsTimerCafe) {
                    Text("목록")
                        .sectionText()
                        ForEach(listManager.cafeList) { listElement in
                            Button(action: {self.selectedCafeName = listElement.name}) {
                                HStack {
                                    Spacer()
                                    Text(listElement.name)
                                    Spacer()
                                }
                                .rowBackground()
                                .foregroundColor(self.getColor(cafeName: listElement.name))
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            tempIsTimerCafe = self.settingManager.alimiCafeName != nil
            self.selectedCafeName = self.settingManager.alimiCafeName
        }
    }
    /// Highlight cafe color if cafe is selected.
    func getColor(cafeName: String) -> Color{
        if cafeName == settingManager.alimiCafeName { return themeColor.icon(colorScheme) }
        else if cafeName == self.selectedCafeName { return Color(.systemGray) }
        else { return Color(.systemFill) }
    }
}

struct TimerSelectView_Previews: PreviewProvider {
    static var previews: some View {
        TimerCafeSettingView()
            .environmentObject(ListManager())
            .environmentObject(SettingManager())
    }
}
