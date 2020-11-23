//
//  BottomBar.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/18.
//

import SwiftUI

struct BottomBar: View {
    
    @State var isMapSheet = false
    @Binding var currentCafe: Cafe?
    @EnvironmentObject var listManager: CafeList
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Button(action: {
                let telephone = "tel://02-"
                let formattedString = telephone + (currentCafe?.phoneNum ?? "")
                guard let url = URL(string: formattedString) else { return }
                UIApplication.shared.open(url)
            }) {
                Image(systemName: "phone")
                    .font(.system(size: 23, weight: .light))
                    .foregroundColor(Color(red: 90/255, green: 196/255, blue: 119/255))
            }
            Spacer()
            Button(action: {
                isMapSheet = true
            }) {
                Image(systemName: "map")
                    .font(.system(size: 23, weight: .light))
                    .foregroundColor(Color(red: 65/255, green: 154/255, blue: 215/255))
            }
            Spacer()
            Button(action: {
                if let cafe = currentCafe {
                    _ = listManager.toggleFixed(cafeName: cafe.name)
                }
            }) {
                Image(systemName: listManager.isFixed(cafeName: currentCafe?.name ?? "없음") ? "pin" : "pin.slash")
                    .font(.system(size: 23, weight: .light))
                    .foregroundColor(Color(red: 147/255, green: 101/255, blue: 179/255))
            }
            Spacer()
            Button(action: {
                withAnimation {
                    self.currentCafe = nil
                }
            }) {
                Text("닫기")
                    .font(.system(size: 23))
                    .foregroundColor(themeColor.title(colorScheme))
            }
        }
        .padding([.leading, .trailing], 20)
        .padding([.top, .bottom], 10)
        .background(
            Blur(style: .systemMaterial)
                .edgesIgnoringSafeArea(.bottom)
                .shadow(radius: 2)
        )
        .sheet(isPresented: $isMapSheet) {
            if let cafe = currentCafe {
                MapView(cafeInfo: cafe)
                    .environmentObject(self.themeColor)
            }
        }
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomBar(currentCafe: .constant(previewCafe))
    }
}
