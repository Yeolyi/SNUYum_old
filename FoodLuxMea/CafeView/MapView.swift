//
//  MapView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI

struct MapView: View {
    let themeColor = ThemeColor()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var cafeInfo: Cafe
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    NaverMap(cafeName: self.cafeInfo.name)
                        .edgesIgnoringSafeArea(.bottom)
                    Text(cafePosition[self.cafeInfo.name] ?? "")
                        .font(.system(size: CGFloat(20), weight: .bold, design: .default))
                        .background(Color.white.opacity(0.8))
                        .position(x: geo.size.width/2 ,y: geo.size.height/10)
                }
            }
            .navigationBarTitle(Text(cafeInfo.name + " 위치 정보"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {self.presentationMode.wrappedValue.dismiss()}){
                                        Text("닫기")
                                            .foregroundColor(themeColor.colorTitle(colorScheme))
                                    })
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
            .sheet(isPresented: .constant(true)) {
                MapView(cafeInfo: Cafe(name: "3식당", phoneNum: "", bkfMenuList: [], lunchMenuList: [], dinnerMenuList: []))
            }
    }
}