//
//  MapView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

/// Show naver map and cafe location text. 
struct MapView: View {
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var cafeInfo: Cafe
    
    /// - Parameter cafeInfo: Determine which cafe's location to show.
    init(cafeInfo: Cafe) {
        self.cafeInfo = cafeInfo
    }
    
    var body: some View {
        VStack {
            HStack {
                customNavigationBar(title: "위치 정보", subTitle: cafeInfo.name)
                Spacer()
                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                    Text("닫기")
                        .font(.system(size: CGFloat(20), weight: .semibold))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding()
                        .offset(y: 10)
                }
            }
            // Cafe location info in text.
            Text(cafePosition[self.cafeInfo.name] ?? "")
                .font(.system(size: CGFloat(20), weight: .semibold, design: .default))
                .centered()
                .rowBackground()
            NaverMapProvider(cafeName: self.cafeInfo.name)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
            .sheet(isPresented: .constant(true)) {
                MapView(cafeInfo: Cafe(name: "학생회관식당"))
            }
    }
}
