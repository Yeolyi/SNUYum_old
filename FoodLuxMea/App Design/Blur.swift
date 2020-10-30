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
    let headerBottomPadding: CGFloat
    let headerView: Content
    
    init(padding: CGFloat, @ViewBuilder headerView: @escaping () -> Content) {
        self.headerBottomPadding = padding
        self.headerView = headerView()
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                headerView
                Spacer()
            }
            .padding(.bottom, headerBottomPadding)
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
    }
}

struct Blur_Previews: PreviewProvider {
    static var previews: some View {
        BlurHeader(padding: 10) {
            CustomHeader(title: "테스트", subTitle: "부제")
        }
    }
}
