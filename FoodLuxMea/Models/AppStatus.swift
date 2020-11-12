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
    
    @Published var isDownloading = false
    
    var isFirstVersionRun = false
    
    let monitor = NWPathMonitor()
    
    @AutoSave("executionTimeCount", defaultValue: 0)
    var executionTimeCount: Int
    
    init() {
        let storedAppVersion = UserDefaults.snuYum.string(forKey: "appVersion")
        if let storedAppVersion = storedAppVersion {
            print("Converting data to new UserDefault system")
            let storedBuild = UserDefaults.snuYum.string(forKey: "build") ?? ""
            UserDefaults.snuYum.set(try? JSONEncoder().encode(storedAppVersion), forKey: "appVersion")
            UserDefaults.snuYum.set(try? JSONEncoder().encode(storedBuild), forKey: "build")
            let storedMealViewMode = MealType(rawValue: UserDefaults.snuYum.string(forKey: "mealViewMode") ?? "점심")
            UserDefaults.snuYum.set(try? JSONEncoder().encode(storedMealViewMode), forKey: "mealViewMode")
            let alimiCafeName = UserDefaults.snuYum.string(forKey: "timerCafeName")
            UserDefaults.snuYum.set(try? JSONEncoder().encode(alimiCafeName), forKey: "timerCafeName")
            let isAuto = UserDefaults.snuYum.bool(forKey: "isAuto")
            UserDefaults.snuYum.set(try? JSONEncoder().encode(isAuto), forKey: "isAuto")
            let hideEmptyCafe = UserDefaults.snuYum.bool(forKey: "isHide")
            UserDefaults.snuYum.set(try? JSONEncoder().encode(hideEmptyCafe), forKey: "isHide")
            if let loadedData = UserDefaults.snuYum.value(forKey: "cafeList") as? Data {
                do {
                    let cafeList = try PropertyListDecoder().decode([ListElement].self, from: loadedData)
                    print(cafeList)
                    UserDefaults.snuYum.set((try? JSONEncoder().encode(cafeList)) ?? [], forKey: "cafeList")
                    
                } catch {
                    assertionFailure("ListManager load error.")
                }
            }
        }
        
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
