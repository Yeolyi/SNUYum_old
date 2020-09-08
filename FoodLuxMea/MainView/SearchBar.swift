//
//  SearchBar.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI


struct SearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    let themeColor = ThemeColor()
    var placeholder: String = "식당이나 메뉴 이름을 검색하세요"
    @Binding var text: String
    var backgroundColor: Color {
      if colorScheme == .dark {
           return Color(.systemGray5)
       } else {
           return Color(.systemGray6)
       }
    }
  
    var body: some View {
        Group {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeColor.colorIcon(colorScheme))
                TextField(placeholder, text: $text)
                if text != "" {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(themeColor.colorIcon(colorScheme))
                        .padding(3)
                        .onTapGesture {
                            withAnimation {
                                self.text = ""
                              }
                        }
                }
            }
            //.padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
        }
        .modifier(ListRow())
    }

}
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Test"))
            .environmentObject(ThemeColor())
    }
}
