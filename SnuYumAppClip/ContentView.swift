//
//  ContentView.swift
//  SnuYumAppClip
//
//  Created by Seong Yeol Yi on 2020/09/24.
//

import SwiftUI
import StoreKit

class ClippedCafeManager: ObservableObject {
    
    @Published var cafeData: [Cafe]
    @Published var date = Date()
    @Published var suggested = DailyProposer.menu(at: Date(), cafeName: "학생회관식당")
    
    init() {
        let ourHomeManager = OurhomeStorage()
        cafeData = SNUCODownloader.download(at: Date())
        if let ourhomeCafe = ourHomeManager.getCafe(date: Date()) {
            cafeData.append(ourhomeCafe)
        }
    }
    
    func update() {
        date = Date()
        suggested = DailyProposer.menu(at: Date(), cafeName: "학생회관식당")
    }
    
}

struct ContentView: View {
    
    @EnvironmentObject var cafeManager: ClippedCafeManager
    @Environment(\.colorScheme) var colorScheme
    @State var showApp = false
    let themeColor = ThemeColor()
    
    var body: some View {
        BlurHeader(
            headerBottomHeading: 10,
            headerView: AnyView(
                            HStack {
                                CustomHeader(title: "식단 바로보기", subTitle: "스누냠 App Clip")
                                Spacer()
                            }
                        )
        ) {
                ScrollView {
                    Text("")
                        .padding(35)
                    Text("모든 기능들을 사용해보시겠어요?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            showApp.toggle()
                        }
                        .centered()
                        .rowBackground()
                    Text("\(cafeManager.suggested.isTomorrow ? "내일" : "오늘") \(cafeManager.suggested.meal.rawValue) 식단입니다")
                        .foregroundColor(themeColor.title(colorScheme))
                        .font(.headline)
                        .centered()
                        .rowBackground()
                    ForEach(cafeManager.cafeData.filter { isMenuEmpty(of: $0) == false }) { cafe in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(cafe.name)
                                    .accentedText()
                                    .foregroundColor(themeColor.title(colorScheme))
                                    .padding(.bottom, 1.5)
                                Spacer()
                            }
                            Spacer()
                            ForEach(cafe.menus(at: cafeManager.suggested.meal).filter { !$0.name.contains("※")}) { menu in
                                HStack {
                                    Text(menu.name)
                                        .font(.system(size: 15))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(1)
                                        .foregroundColor(Color(.label))
                                    Spacer()
                                    Text(menu.costInterpret())
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
        cafe.menus(at: DailyProposer.menu(at: Date(), cafeName: cafe.name).meal).isEmpty
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ClippedCafeManager())
    }
}
