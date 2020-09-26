//
//  SwiftUIView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/26.
//

import SwiftUI

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct BlurHeader<Content: View>: View {
    let headerBottomHeading: CGFloat
    let headerView: AnyView
    let content: () -> Content

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    headerView
                    Spacer()
                }
                .padding(.bottom, headerBottomHeading)
                .background(
                    Blur(style: .systemUltraThinMaterial)
                        .clipShape(
                            RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight])
                        )
                        .edgesIgnoringSafeArea(.top)
                        .shadow(radius: 5)
                    )
                Spacer()
            }
            .zIndex(1)
            content()
        }
    }
}

struct Blur_Previews: PreviewProvider {
    static var previews: some View {
        BlurHeader(
            headerBottomHeading: 10,
            headerView: AnyView(CustomHeader(title: "테스트", subTitle: "부제"))
        ) {
            List {
                ForEach(0..<50) { i in
                    Rectangle()
                        .foregroundColor(i % 2 == 0 ? .red : .blue)
                        .centered()
                }
            }
        }
    }
}
