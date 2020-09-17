//
//  SearchBar.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Searchbar containing magnifying glass symbol and text clear feature.
struct SearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    let themeColor = ThemeColor()
    
    /// - Parameter text: Binding string which passes entered text.
    init(text: Binding<String>) {
        self._text = text
    }

    var body: some View {
        Group {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeColor.icon(colorScheme))
                TextField("메뉴 이름을 검색하세요", text: $text)
                // When text exists, show delete button.
                if text != "" {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(themeColor.icon(colorScheme))
                        .padding(3)
                        .onTapGesture {
                            withAnimation {
                                self.text = ""
                              }
                        }
                }
            }
            .foregroundColor(.secondary)
        }
        .listRow()
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Test"))
            .environmentObject(ThemeColor())
    }
}
