//
//  SearchBar.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Searchbar containing magnifying glass symbol and text clear feature.
struct SearchBar: View {
    
    @Binding var searchWord: String
    
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    
    /// - Parameter text: Binding string which passes entered text.
    init(searchWord: Binding<String>) {
        self._searchWord = searchWord
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeColor.icon(colorScheme))
            TextField("메뉴 이름을 검색하세요", text: $searchWord)
            // When text exists, show delete button.
            if searchWord != "" {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(themeColor.icon(colorScheme))
                    .padding(3)
                    .onTapGesture {
                        withAnimation {
                            self.searchWord = ""
                        }
                    }
            }
        }
        .foregroundColor(.secondary)
        .rowBackground()
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchWord: .constant("Test"))
            .environmentObject(ThemeColor())
    }
}
