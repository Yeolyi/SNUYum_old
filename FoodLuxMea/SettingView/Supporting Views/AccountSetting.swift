//
//  AccountSetting.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/19.
//

import SwiftUI
import FirebaseAuth

struct AccountSetting: View {
   
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("스누냠의 더 많은 기능")
                .foregroundColor(themeColor.title(colorScheme))
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding(.top, 40)
                .padding(.bottom, 3)
            Text("로그인 후 바로 사용하세요")
                .font(.system(size: 20, weight: .bold, design: .default))
                .padding(.bottom, 40)
                .foregroundColor(.secondary)
            HStack {
                Image(systemName: "star")
                    .font(.system(size: 45, weight: .light))
                    .foregroundColor(themeColor.icon(colorScheme))
                    .padding(.leading, 30)
                VStack(alignment: .leading) {
                    Text("식단 평가하기")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    Text("누군가의 학식 인생을 바꾸어보세요.")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            Spacer()
            SignInWithAppleToFirebase { _ in
                
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .padding(30)
            .padding(.bottom, 40)
        }
    }
}

struct AccountSetting_Previews: PreviewProvider {
    static var previews: some View {
        AccountSetting()
    }
}
