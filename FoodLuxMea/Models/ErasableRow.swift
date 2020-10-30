//
//  ErasableRow.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/10/30.
//

import Foundation

class ErasableRowManager: ObservableObject {
    
    @Published var erasableMessages = [String]()
    let firstInstallMessages = ["생협 공지: 코로나19 수도권 사회적 거리두기 강화에 따라 점심식사 이용 시 식당 혼잡시간을 피하여 이용을 부탁드립니다."]
    let messages = [
        """
    [1.5 업데이트 내역]
    - 위젯 기능이 추가되었어요! 홈화면에서 식단을 바로 확인해보세요. 위젯을 길게 눌러 설정할 수 있어요.
    - iPad를 지원해요.
    """
    ]
    
    init() {
        if let userDefaults = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            if let savedValue = userDefaults.object(forKey: "erasableMessages") as? [String] {
                print("ErasableRow loaded.")
                erasableMessages = savedValue
                if appStatus.isFirstVersionRun {
                    erasableMessages += messages
                }
            } else {
                erasableMessages = firstInstallMessages + messages
            }
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

extension String: Identifiable {
    public var id: UUID {
        UUID()
    }
}
