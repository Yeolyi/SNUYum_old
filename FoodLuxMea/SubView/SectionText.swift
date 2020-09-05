//
//  SectionText.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI


struct SectionText: ViewModifier {
    func body(content: Content) -> some View {
        content
        .font(.system(size: CGFloat(20), weight: .semibold, design: .default))
        .foregroundColor(.primary)
    }
}

struct SectionTextSmaller: ViewModifier {
    func body(content: Content) -> some View {
        content
        .font(.system(size: CGFloat(16), weight: .semibold, design: .default))
        .foregroundColor(.primary)
    }
}


struct SectionText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("SectionText Test")
            .modifier(SectionText())
            Text("SectionTextSmaller Test")
            .modifier(SectionTextSmaller())
        }
    }
}
