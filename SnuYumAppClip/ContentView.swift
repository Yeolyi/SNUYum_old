//
//  ContentView.swift
//  SnuYumAppClip
//
//  Created by Seong Yeol Yi on 2020/09/24.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @State var cafeteria = ClippedCafeteria()
    @State var showApp = false
    
    @Environment(\.colorScheme) var colorScheme
    let themeColor = ThemeColor()
    var proposer = DailyProposer(at: Date(), cafeName: "학생회관식당")
    
    var body: some View {
        ZStack {
            BlurHeader(padding: 10) {
                HStack {
                    CustomHeader(title: "식단 바로보기", subTitle: "스누냠 App Clip")
                    Spacer()
                }
            }
            .zIndex(1)
            ScrollView {
                Text("")
                    .padding(35)
                Button(action: {showApp.toggle()}) {
                    Text("모든 기능들을 사용해보시겠어요?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .centered()
                        .rowBackground()
                }
                Text("\(proposer.isTomorrow ? "내일" : "오늘") \(proposer.meal.rawValue) 식단입니다")
                    .foregroundColor(themeColor.title(colorScheme))
                    .font(.headline)
                    .centered()
                    .rowBackground()
                ForEach(cafeteria.asyncData.filter { isMenuEmpty(of: $0) == false }) { cafe in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(cafe.name)
                                .accentedText()
                                .foregroundColor(themeColor.title(colorScheme))
                                .padding(.bottom, 1.5)
                            Spacer()
                        }
                        Spacer()
                        ForEach(cafe.menus(at: .lunch).filter { !$0.name.contains("※")}) { menu in
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
                        }
                    }
                    .rowBackground()
                }
            }
        }
        .appStoreOverlay(isPresented: $showApp, configuration: {SKOverlay.AppClipConfiguration(position: .bottom)})
    }
    
    func isMenuEmpty(of cafe: Cafe) -> Bool {
        cafe.menus(at: DailyProposer(at: Date(), cafeName: cafe.name).meal).isEmpty
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
