//
//  GoogleLogin.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct GoogleLogin: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            GIDSignIn.sharedInstance().presentingViewController =
            UIApplication.shared.windows.first?.rootViewController
            GIDSignIn.sharedInstance()?.signIn()
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .padding([.top, .bottom], 18)
                Text("Google로 로그인")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
            )
        .padding([.leading, .trailing], 30)
    }
}

struct GoogleLogin_Previews: PreviewProvider {
    static var previews: some View {
        GoogleLogin()
    }
}
