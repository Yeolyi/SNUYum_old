//
//  RuntimeManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/23.
//

import SwiftUI
import Network
import StoreKit

class AppStatus: ObservableObject {
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    private let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    @Published var isInternetConnected = false
    
    var isFirstVersionRun = false
    
    let monitor = NWPathMonitor()
    
    var executionTimeCount: Int = 0
    
    init() {
        
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            // To delete garbage data from previous versions.
            userDefault.removeObject(forKey: "1.1firstRun")
            
            let storedAppVersion = userDefault.string(forKey: "appVersion") ?? ""
            let storedBuild = userDefault.string(forKey: "build") ?? ""
            if storedAppVersion != appVersion || storedBuild != build {
                print("Version first run TRUE.")
                isFirstVersionRun = true
                userDefault.set(appVersion as String, forKey: "appVersion")
                userDefault.set(build as String, forKey: "build")
            } else {
                isFirstVersionRun = false
                print("Version first run FALSE.")
            }
            
            executionTimeCount = userDefault.integer(forKey: "executionTimeCount")
            print("\(executionTimeCount) times executed.")
            executionTimeCount += 1
            userDefault.set(executionTimeCount as Int, forKey: "executionTimeCount")
        } else {
            assertionFailure("Userdefault failed in RuntimeManager")
        }
        
        // Update variable isInternetConnected using Network framework
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isInternetConnected = true
                    print("인터넷 연결됨")
                } else {
                    self.isInternetConnected = false
                    print("인터넷 연결되지 않음")
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
