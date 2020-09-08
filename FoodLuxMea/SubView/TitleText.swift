//
//  TitleText.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/30.
//

import SwiftUI


struct TitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(18), weight: .medium, design: .default))
        //.font(.custom("NanumBarunpenR", size: 18))
    }
}


struct TitleText_Previews: PreviewProvider {
    static var previews: some View {
        Text("왜안대")
        .modifier(TitleText())
    }
}
