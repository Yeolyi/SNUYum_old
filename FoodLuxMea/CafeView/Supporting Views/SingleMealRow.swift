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
                HStack(spacing: 0) {
                    Text(menu.name)
                        .accentedText()
                        .foregroundColor(self.themeColor.title(self.colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    if asyncRating.rating != nil {
                        Image(systemName: asyncRating.isRated ? "star.fill": "star")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.lightGray))
                        Text(asyncRating.rating!)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(.lightGray))
                            .padding(.trailing, 7)
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
    
    @Published var participants: Int?
    @Published var rating: String?
    @Published var myRate: Int?
    @Published var isRated: Bool = false
    
    init(_ ratedMenuInfo: RatedMenuInfo) {
        RatingMessenger.getMenuRating(info: ratedMenuInfo) { values in
            if let values = values {
                self.rating = String(round(values.0*10)/10)
                self.participants = values.1
            }
        }
        RatingMessenger.isAlreadyRated(ratedMenuInfo) { isRated in
            self.isRated = isRated
        }
        RatingMessenger.getMyRate(ratedMenuInfo) { rate in
            self.myRate = rate
        }
    }
}

struct SingleMealRow_Previews: PreviewProvider {
    
    static let testMenuInfo = RatedMenuInfo(at: Date(), cafe: "3식당", menu: "테스트 메뉴")
    
    static var previews: some View {
        SingleMealRow(
            menu: Menu(name: "테스트 메뉴"),
            ratedMenuInfo: testMenuInfo,
            ratedCafe: .constant(testMenuInfo),
            isRatingWindow: .constant(false)
        )
    }
}
