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
    
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var settingManager: UserSetting
    let themeColor = ThemeColor()
    
    @State var selectedCafeName: String?
    
    /*
     let timerGuide = """
     선택된 식당의 운영시간을 기준으로 아침, 점심, 저녁을 자동으로 보여드립니다.
     학생회관식당: 1층 기준
     자하연 식당: 2층(학생식당) 기준
     3식당: 4층 기준
     301동 식당: 지하 기준
     """
     */
    var body: some View {
        VStack {
            // MARK: - Custom Navigation bar.
            HStack {
                CustomHeader(title: "기준 식당 선택", subTitle: "설정")
                Spacer()
                Button(action: {
                        self.presentationMode.wrappedValue.dismiss()}) {
                    Text("취소")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .offset(y: 10)
                }
                Button(action: {
                        self.settingManager.alimiCafeName = self.selectedCafeName
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
                    HStack {
                        Spacer()
                        Text("선택된 식당의 운영시간을 기준으로 아침, 점심, 저녁을 자동으로 보여드립니다.")
                        Spacer()
                    }
                    .rowBackground()
                    // MARK: - Selectable cafe list.
                    Text("식당 목록")
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
        .onAppear {
            self.selectedCafeName = self.settingManager.alimiCafeName
        }
    }
    /// Highlight cafe color if cafe is selected.
    func getColor(cafeName: String) -> Color {
        if cafeName == settingManager.alimiCafeName {
            return themeColor.icon(colorScheme)
        } else if cafeName == self.selectedCafeName {
            return Color(.systemGray)
        } else {
            return Color(.systemFill)
        }
    }
}

struct TimerSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let cafeList = CafeList()
        cafeList.clear()
        return TimerCafeSettingView()
            .environmentObject(cafeList)
            .environmentObject(UserSetting())
    }
}
