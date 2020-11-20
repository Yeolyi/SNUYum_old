//
//  RatingWindow.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/20.
//

import SwiftUI
import Firebase

struct RatingWindow: View {
    
    @Binding var isShown: Bool
    @ObservedObject var asyncRating = AsyncRating(.init(at: Date(), cafe: "a", menu: "a"))
    let ratedMenuInfo: RatedMenuInfo
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    
    init(isShown: Binding<Bool>, ratedMenuInfo: RatedMenuInfo) {
        self._isShown = isShown
        self.ratedMenuInfo = ratedMenuInfo
        asyncRating = AsyncRating(ratedMenuInfo)
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("\"\(ratedMenuInfo.menuName)\"은 어떠셨나요?")
                    .accentedText()
                    .foregroundColor(themeColor.title(colorScheme))
                    .padding(.bottom, 3)
                if asyncRating.rating != nil && asyncRating.participants != nil {
                    Text("현재 평점: \(asyncRating.rating!)(\(asyncRating.participants!)명 참가)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                } else {
                    Text("첫 평점을 남겨보세요!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                HStack {
                    Button(action: {self.asyncRating.myRate = 1}) {
                        Image(systemName: self.asyncRating.myRate ?? 3 >= 1 ? "star.fill" : "star")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                    }
                    Button(action: {self.asyncRating.myRate = 2}) {
                        Image(systemName: self.asyncRating.myRate ?? 3 >= 2 ? "star.fill" : "star")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                    }
                    Button(action: {self.asyncRating.myRate = 3}) {
                        Image(systemName: self.asyncRating.myRate ?? 3 >= 3 ? "star.fill" : "star")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                    }
                    Button(action: {self.asyncRating.myRate = 4}) {
                        Image(systemName: self.asyncRating.myRate ?? 3 >= 4 ? "star.fill" : "star")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                    }
                    Button(action: {self.asyncRating.myRate = 5}) {
                        Image(systemName: self.asyncRating.myRate ?? 3 >= 5 ? "star.fill" : "star")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeColor.icon(colorScheme))
                    }
                }
                .padding(.bottom, 40)
                HStack {
                    if asyncRating.isRated {
                        Button(action: {
                            RatingMessenger.deleteMyRate(ratedMenuInfo)
                            self.isShown = false
                        }) {
                            Text("삭제")
                                .font(.system(size: 20))
                                .foregroundColor(Color(.lightGray))
                                .fixedSize()
                        }
                        .padding(.leading, 20)
                    }
                    Spacer()
                    Button(action: {
                        self.isShown = false
                    }) {
                        Text("취소")
                            .font(.system(size: 20))
                            .foregroundColor(Color(.lightGray))
                            .fixedSize()
                    }
                    .padding(.trailing, 40)
                    Button(action: {
                        RatingMessenger.sendIndividualRating(info: ratedMenuInfo, star: self.asyncRating.myRate ?? 3)
                        self.isShown = false
                    }) {
                        Text(asyncRating.isRated ? "다시 등록" : "등록")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .fixedSize()
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 10)
            }
            .padding(30)
            .background(
                Blur(style: .systemMaterial)
                    .edgesIgnoringSafeArea(.top)
                    .shadow(radius: 2)
            )
            .padding(.top, 50)
            Spacer()
        }
    }
    
}

struct RatingWindow_Previews: PreviewProvider {
    static var previews: some View {
        RatingWindow(isShown: .constant(true), ratedMenuInfo: RatedMenuInfo(at: Date(), cafe: "3식당", menu: "테스트"))
    }
}
