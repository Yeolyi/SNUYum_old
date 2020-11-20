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
    @State var ratingValue: Int = 3
    let ratedMenuInfo: RatedMenuInfo
    
    var body: some View {
        VStack {
            Text("\(ratedMenuInfo.date)에 \(ratedMenuInfo.cafeName)에서의 \(ratedMenuInfo.menuName)을 평가합니다.")
            HStack {
                Button(action: {self.ratingValue = 1}) {
                    Image(systemName: ratingValue >= 1 ? "star.fill" : "star")
                }
                Button(action: {self.ratingValue = 2}) {
                    Image(systemName: ratingValue >= 2 ? "star.fill" : "star")
                }
                Button(action: {self.ratingValue = 3}) {
                    Image(systemName: ratingValue >= 3 ? "star.fill" : "star")
                }
                Button(action: {self.ratingValue = 4}) {
                    Image(systemName: ratingValue >= 4 ? "star.fill" : "star")
                }
                Button(action: {self.ratingValue = 5}) {
                    Image(systemName: ratingValue >= 5 ? "star.fill" : "star")
                }
            }
            .padding(.bottom, 20)
            HStack {
                Button(action: {
                    self.isShown = false
                }) {
                    Text("취소")
                }
                .padding(.trailing, 40)
                Button(action: {
                    RatingMessenger.sendIndividualRating(info: ratedMenuInfo, star: ratingValue)
                    self.isShown = false
                }) {
                    Text("보내기")
                }
            }
        }
        .frame(width: 300, height: 300)
        .background(
            Color.white
                .shadow(radius: 3)
        )
    }
    
}

struct RatingWindow_Previews: PreviewProvider {
    static var previews: some View {
        RatingWindow(isShown: .constant(true), ratedMenuInfo: RatedMenuInfo(at: Date(), cafe: "3식당", menu: "테스트"))
    }
}
