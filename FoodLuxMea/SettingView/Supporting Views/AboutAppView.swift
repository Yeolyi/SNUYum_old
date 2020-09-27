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
            // MARK: - Snuyum app icon.
            Image("Icon-1024")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            // MARK: - ScrollView.
            ScrollView {
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
                Text("자료 참조")
                    .sectionText()
                HStack {
                    Spacer()
                    Text("서울대학교생활협동조합")
                    Spacer()
                }
                .rowBackground()
                HStack {
                    Spacer()
                    Text("서울대학교 캠퍼스 맵")
                    Spacer()
                }
                .rowBackground()
                Text("개발자")
                    .sectionText()
                HStack {
                    Spacer()
                    Text("이성열")
                    Spacer()
                }
                .rowBackground()
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
            .environmentObject(ThemeColor())
    }
}
