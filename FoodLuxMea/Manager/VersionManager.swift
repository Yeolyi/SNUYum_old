//
//  VersionManager.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/09/21.
//

import Foundation

struct VersionChecker {
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    init() {
        if let userDefault = UserDefaults(suiteName: "group.com.wannasleep.FoodLuxMea") {
            userDefault.removeObject(forKey: "1.1firstRun")
            let storedAppVersion = userDefault.string(forKey: "appVersion") ?? ""
            let storedBuild = userDefault.string(forKey: "build") ?? ""
            if storedAppVersion != appVersion || storedBuild != build {
                print("Version first run TRUE.")
                isFirstVersionRun = true
            } else {
                isFirstVersionRun = false
                print("Version first run FALSE.")
            }
            userDefault.set(appVersion as String, forKey: "appVersion")
            userDefault.set(build as String, forKey: "build")
        }
    }
}
