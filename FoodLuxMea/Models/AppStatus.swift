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
    
    @AutoSave("appVersion", defaultValue: "")
    private var appVersion: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AutoSave("build", defaultValue: "")
    private var build: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var isInternetConnected = false
    
    var isFirstVersionRun = false
    
    let monitor = NWPathMonitor()
    
    @AutoSave("executionTimeCount", defaultValue: 0)
    var executionTimeCount: Int
    
    init() {
        executionTimeCount += 1
        print("\(executionTimeCount) time executed.")
        let currentBuild = (Bundle.main.infoDictionary?["CFBundleVersionString"] as? String) ?? ""
        let currentAppVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        if appVersion != currentAppVersion || build != currentBuild {
            isFirstVersionRun = true
            appVersion = currentAppVersion
            build = currentBuild
        }
        if executionTimeCount > 20 {
            SKStoreReviewController.requestReview()
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
