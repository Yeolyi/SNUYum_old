//
//  Extensions.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

struct CenterModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct ListRow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        Group {
            content
                .padding(10)
                .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.gray.opacity(0.05))
                .cornerRadius(13)
        }
        .padding([.top, .bottom], 2)
        .padding([.leading, .trailing], 10)
    }
}

struct SectionTextModifier: ViewModifier {
    func body(content: Content) -> some View {
         HStack {
             content
                 .modifier(TitleText())
                 .padding([.top, .bottom], 5)
                 .padding(.leading, 12)
             Spacer()
         }
    }
}

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

