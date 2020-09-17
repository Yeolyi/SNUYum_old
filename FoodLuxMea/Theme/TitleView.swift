//
//  TitleView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/18.
//

import SwiftUI

/// Simple custom navigaion bar
func TitleView(title: String, subTitle: String) -> AnyView{
    return AnyView (
        HStack {
            VStack(alignment: .leading) {
                Text(subTitle)
                    .font(.system(size: CGFloat(18), weight: .bold))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.system(size: CGFloat(25), weight: .bold))
            }
            .padding([.leading, .top])
            Spacer()
        }
    )
}
