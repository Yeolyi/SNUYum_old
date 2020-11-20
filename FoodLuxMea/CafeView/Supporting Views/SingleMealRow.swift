//
//  SingleMealRow.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/20.
//

import SwiftUI

struct SingleMealRow: View {
    
    let menu: Menu
    let themeColor = ThemeColor()
    let ratedMenuInfo: RatedMenuInfo
    @Binding var ratedCafe: RatedMenuInfo
    @Binding var isRatingWindow: Bool
    @ObservedObject var asyncRating = AsyncRating(.init(at: Date(), cafe: "a", menu: "a"))
    @Environment(\.colorScheme) var colorScheme
    
    init(menu: Menu, ratedMenuInfo: RatedMenuInfo, ratedCafe: Binding<RatedMenuInfo>, isRatingWindow: Binding<Bool>) {
        self.menu = menu
        self.ratedMenuInfo = ratedMenuInfo
        self._ratedCafe = ratedCafe
        self._isRatingWindow = isRatingWindow
        asyncRating = AsyncRating(ratedMenuInfo)
    }
    
    var body: some View {
        VStack {
            Button(action: {
                ratedCafe = ratedMenuInfo
                isRatingWindow = true
            }) {
                HStack {
                    Text(menu.name)
                        .accentedText()
                        .foregroundColor(self.themeColor.title(self.colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    if asyncRating.rating != nil {
                        Image("star")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.lightGray))
                            .padding(.trailing, 3)
                        Text(asyncRating.rating!)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(.lightGray))
                    }
                    Text(menu.costStr)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.gray))
                }
            }
        }
        .rowBackground()
    }
}

class AsyncRating: ObservableObject {
    @Published var rating: String?
    init(_ ratedMenuInfo: RatedMenuInfo) {
        RatingMessenger.getMenuRating(info: ratedMenuInfo) { value in
            if let value = value {
                self.rating = String(round(value*10)/10)
            }
        }
    }
}
