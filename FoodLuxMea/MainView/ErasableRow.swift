//
//  ErasableRow.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/23.
//

import SwiftUI

class ErasableRowManager: ObservableObject {
    
    @Published var erasableMessages = [String]()

    let messages = [
        "1.6 업데이트: iPad를 지원해요."
    ]
    
    init() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if let savedValue = userDefaults.object(forKey: "erasableMessages") as? [String] {
                print("ErasableRow loaded.")
                erasableMessages = savedValue
            } else {
                print("ErasableMessage initialized to default value.")
                erasableMessages = messages
                return
            }
        }
        if appStatus.isFirstVersionRun {
            erasableMessages += messages
        }
    }
    
    func save() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            userDefaults.setValue(erasableMessages, forKey: "erasableMessages")
        }
    }
    
    func clear() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            erasableMessages = messages
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
            ForEach(erasableRowManager.erasableMessages, id: \.self) { erasableMessage in
                HStack {
                    Text(erasableMessage)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            withAnimation {
                                erasableRowManager.remove(erasableMessage)
                            }
                        }
                        .padding(5)
                }
                .transition(.opacity)
                .rowBackground()
            }
    }
}

struct ErasableRow_Previews: PreviewProvider {
    static var previews: some View {
        ErasableRow()
    }
}
