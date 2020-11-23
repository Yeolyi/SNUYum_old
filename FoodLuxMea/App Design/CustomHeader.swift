//
//  TitleView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/18.
//

import SwiftUI

/// Simple custom navigaion bar
struct CustomHeader: View {
    let title: String
    let subTitle: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(subTitle)
                    .font(.system(size: CGFloat(18), weight: .bold))
                    .foregroundColor(.secondary)
                    .animation(nil)
                Text(title)
                    .font(.system(size: CGFloat(25), weight: .bold))
                    .animation(nil)
                    
            }
            .padding([.leading, .top])
        }
    }
}
