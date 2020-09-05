//
//  InfoView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

struct InfoView: View {
    
    var body: some View {
        listByVersion(view: AnyView(
            InfoViewContent()
        ))
    }

}

struct InfoViewContent: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    let themeColor = ThemeColor()
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let build = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("Icon-1024")
                .resizable()
                .scaledToFit()
                .frame(width: 150.0,height:150)
                List {
                    Section(header: Text("버전")) {
                        Text(appVersion)
                    }
                    Section(header: Text("빌드")) {
                        Text(build)
                    }
                    Section(header: Text("자료 참조")) {
                        Text("서울대학교생활협동조합 홈페이지\n(snuco.snu.ac.kr)")
                        Text("서울대학교 캠퍼스 맵\n(map.snu.ac.kr)")
                    }
                    Section(header: Text("개발자")) {
                        Text("이성열")
                    }
                }
            }
            .navigationBarTitle(Text("스누냠 정보"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {self.presentationMode.wrappedValue.dismiss()}){
                                        Text("닫기")
                                            .foregroundColor(themeColor.colorTitle(colorScheme))
                                    })
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
            .environmentObject(ThemeColor())
    }
}
