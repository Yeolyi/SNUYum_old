//
//  ErasableRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/23.
//

import SwiftUI

class ErasableRowManager: ObservableObject {
    
    @Published var erasableMessages = [String]()
    
    let messagesDefault = [String]()
    let newMessages = ["생협 공지: 코로나19 수도권 사회적 거리두기 강화에 따라 점심식사 이용 시 식당 혼잡시간을 피하여 이용을 부탁드립니다."]
    
    init() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if let savedValue = userDefaults.object(forKey: "erasableMessages") as? [String] {
                print("ErasableRow loaded.")
                erasableMessages = savedValue
            } else {
                print("ErasableMessage initialized to default value.")
                erasableMessages = messagesDefault
                print(erasableMessages)
            }
        }
        if RuntimeManager.isFirstVersionRun {
            erasableMessages += newMessages
        }
    }
    
    func clear() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            erasableMessages = messagesDefault + newMessages
            print(erasableMessages)
            userDefaults.setValue(erasableMessages, forKey: "erasableMessages")
        }
    }
    
    func remove(_ message: String) {
        if let index = erasableMessages.firstIndex(of: message) {
            erasableMessages.remove(at: index)
        }
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            print("ErasableRow saved.")
            userDefaults.setValue(erasableMessages, forKey: "erasableMessages")
        }
    }
}

struct ErasableRow: View {
    
    @EnvironmentObject var erasableRowManager: ErasableRowManager
    
    let themeColor = ThemeColor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ForEach(erasableRowManager.erasableMessages, id: \.self) { erasableMessage in
                HStack {
                    Text(erasableMessage)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(themeColor.icon(colorScheme))
                        .onTapGesture {
                            withAnimation {
                                erasableRowManager.remove(erasableMessage)
                            }
                        }
                }
                .transition(.opacity)
                .rowBackground()
            }
        }
    }
}

struct ErasableRow_Previews: PreviewProvider {
    static var previews: some View {
        ErasableRow()
    }
}
