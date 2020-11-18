//
//  CafeListRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/23.
//

import SwiftUI

/// Single row in main view which shows one meal info
struct CafeRow: View {
    
    var cafe: Cafe
    var suggestedMeal: MealType
    let searchText: String
    @Binding var selectedCafe: Cafe?
    
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listManager: CafeList
    @EnvironmentObject var settingManager: UserSetting
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedCafe = cafe
            }
        }) {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(cafe.name)
                        .accentedText()
                        .foregroundColor(themeColor.title(colorScheme))
                        .padding(.bottom, 1.5)
                    Spacer()
                    if listManager.isFixed(cafeName: cafe.name) {
                        Image(systemName: listManager.isExpanded(cafeName: cafe.name) ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(themeColor.icon(colorScheme))
                            .font(.system(size: 20, weight: .semibold, design: .default))
                            .onTapGesture {
                                listManager.toggleExpanded(cafeName: cafe.name)
                            }
                    }
                }
                .padding([.top, .bottom], 5)
                if searchText == "" {
                    if listManager.isExpanded(cafeName: cafe.name) {
                        mealView(mealType: .breakfast)
                        mealView(mealType: .lunch)
                        mealView(mealType: .dinner)
                    } else {
                        if cafe.isEmpty(at: [settingManager.meal], emptyKeywords: []) {
                            HStack {
                                Text("메뉴가 없어요")
                                    .font(.system(size: 15))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .foregroundColor(Color(.label))
                                Spacer()
                            }
                        }
                        ForEach(cafe.menus(at: suggestedMeal).filter { !$0.name.contains("※")}) { menu in
                            HStack {
                                Text(menu.name)
                                    .font(.system(size: 15))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .foregroundColor(Color(.label))
                                Spacer()
                                Text(menu.costStr)
                                    .font(.system(size: 15))
                                    .padding(.trailing, 10)
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                            .padding(.bottom, 1)
                        }
                    }
                } else {
                    VStack {
                        if cafe.includes(searchText, at: [.breakfast]) {
                            searchResult(at: .breakfast)
                        }
                        if cafe.includes(searchText, at: [.lunch]) {
                            searchResult(at: .lunch)
                        }
                        if cafe.includes(searchText, at: [.dinner]) {
                            searchResult(at: .dinner)
                        }
                    }
                }
            }
        }
        .optionalRowBackground(isAccented: listManager.isFixed(cafeName: cafe.name))
    }
    
    func mealView(mealType: MealType) -> AnyView {
        AnyView(
            VStack {
                HStack {
                    Text(mealType.rawValue)
                        .padding(.top, 0.5)
                        .foregroundColor(themeColor.icon(colorScheme))
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                if cafe.menus(at: mealType).filter { !$0.name.contains("※")}.isEmpty {
                    HStack {
                        Text("메뉴가 없어요")
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .foregroundColor(Color(.label))
                        Spacer()
                    }
                }
                ForEach(cafe.menus(at: mealType).filter { !$0.name.contains("※")}) { menu in
                    HStack {
                        Text(menu.name)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .foregroundColor(Color(.label))
                        Spacer()
                        Text(menu.costStr)
                            .font(.system(size: 15))
                            .padding(.trailing, 10)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .padding(.bottom, 1)
                }
            }
        )
    }
    
    func searchResult(at mealType: MealType) -> AnyView {
        
        func highlight(text: String, target: String) -> Text {
            var colorSet: Set<Int> = []
            if let range = text.range(of: target) {
                let index: Int = text.distance(from: text.startIndex, to: range.lowerBound)
                for i in 0..<searchText.count {
                    colorSet.insert(index + i)
                }
                
                var tempView: Text = .init("")
                
                func getView(cnt: Int) -> Text {
                    if cnt == text.count {
                        return tempView
                    }
                    tempView = tempView +
                        (Text(String(text[text.index(text.startIndex, offsetBy: cnt)]))
                            .foregroundColor(colorSet.contains(cnt) ? .primary : .secondary))
                    return getView(cnt: cnt + 1)
                }
                
                return getView(cnt: 0)
            } else { return Text(text) }
        }
        
        return AnyView(
            VStack {
                HStack {
                    Text(mealType.rawValue)
                        .padding(.top, 0.5)
                        .foregroundColor(themeColor.icon(colorScheme))
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                ForEach(cafe.menus(at: mealType).filter { $0.name.contains(searchText) }) { menu in
                    HStack {
                        highlight(text: menu.name, target: self.searchText)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                        Text(menu.costStr)
                            .font(.system(size: 15))
                            .padding(.trailing, 10)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        )
    }
}

struct CafeListRow_Previews: PreviewProvider {
    static var previews: some View {
        let cafeList = CafeList()
        _ = cafeList.toggleFixed(cafeName: "3식당")
        return CafeRow(cafe: previewCafe, suggestedMeal: .lunch, searchText: "", selectedCafe: .constant(nil))
            .environmentObject(cafeList)
            .environmentObject(Cafeteria())
            .environmentObject(UserSetting())
    }
}
