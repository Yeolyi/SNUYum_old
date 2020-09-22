//
//  NavigationBackground.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/23.
//

import SwiftUI

struct NavigationBackground: View {
    var body: some View {
        VStack {
            Triangle()
                .frame(height: 40)
                .foregroundColor(.gray)
            HStack {
                customNavigationBar(title: "테스트", subTitle: "부제")
                Spacer()
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct NavigationBackground_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBackground()
    }
}
