//
//  InfoView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

/// Show various information about app.
struct AboutAppView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settingManager: UserSetting
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var dataManager: Cafeteria
    @State var activeAlert: ActiveAlert?
    let themeColor = ThemeColor()
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    var body: some View {
        VStack {
            // MARK: - Custom navigationbar.
            HStack {
                CustomHeader(title: "스누냠 정보", subTitle: "설정")
                Spacer()
                Button(
                    action: { self.presentationMode.wrappedValue.dismiss()}) {
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            Divider()
            // MARK: - ScrollView.
            ScrollView {
                VStack(spacing: 0) {
                    Text("버전")
                        .sectionText()
                    HStack {
                        Spacer()
                        Text("\(appVersion)(\(build))")
                        Spacer()
                    }
                    .rowBackground()
                    if #available(iOS 14, *) {
                        Text("관련 링크")
                            .sectionText()
                        HStack {
                            Spacer()
                            Link("소스코드(github)",
                                 destination: URL(string: "https://github.com/Yeolyi/SNUYum")!)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .rowBackground()
                        HStack {
                            Spacer()
                            Link("어플리케이션 지원",
                                 destination: URL(string: "https://yeolyi.github.io/SnuYumSupport/")!)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .rowBackground()
                    }
                    Text("개발자")
                        .sectionText()
                    HStack {
                        Spacer()
                        Text("이성열")
                        Spacer()
                    }
                    .rowBackground()
                    // Advanced setting.
                    Group {
                        Text("디버그")
                            .sectionText()
                        // Advanced setting - custom date.
                        SimpleToggle(isOn: $settingManager.isDebugDate, label: "사용자 설정 날짜")
                            .rowBackground()
                        if settingManager.isDebugDate {
                            DatePicker(selection: $settingManager.debugDate, label: { EmptyView() })
                                .rowBackground()
                                .accentColor(themeColor.title(colorScheme))
                        }
                        HStack {
                            Text("저장된 식단 삭제")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .rowBackground()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeAlert = ActiveAlert.clearCafe
                        }
                        HStack {
                            Text("전체 초기화")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .rowBackground()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeAlert = ActiveAlert.clearAll
                        }
                    }
                }
            }
            
        }
        .alert(item: $activeAlert) { item in
            mainAlert(item: item)
        }
    }
    private func mainAlert(item: ActiveAlert) -> Alert {
        switch item {
        case .clearCafe:
            return Alert(
                title: Text("다운로드된 데이터를 삭제합니다"),
                message: Text("사용자 설정은 영향받지 않습니다."),
                primaryButton: .destructive(Text("삭제"), action: { dataManager.clear()}),
                secondaryButton: .cancel()
            )
        case .clearAll:
            return Alert(
                title: Text("앱을 초기 상태로 되돌립니다."),
                primaryButton: .destructive(Text("삭제"), action: {
                    dataManager.clear()
                    settingManager.clear()
                    listManager.clear()
                }
                ),
                secondaryButton: .cancel()
            )
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
            .environmentObject(ThemeColor())
    }
}
