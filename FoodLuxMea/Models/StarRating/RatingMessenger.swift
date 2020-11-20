//
//  RatingMessenger.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/20.
//

import Foundation
import Firebase

struct RatingMessenger {
    
    static func sendIndividualRating(info ratedMenuInfo: RatedMenuInfo, star starValue: Int) {
        let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
        let ref = Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Int] {
                if let id = appStatus.userID {
                    var newValue = value
                    newValue[id] = starValue
                    ref.setValue(newValue)
                }
            } else {
                if let id = appStatus.userID {
                    ref.setValue([id: starValue])
                }
            }
        }
    }
    
    static func getMenuRating(info ratedMenuInfo: RatedMenuInfo, completion: @escaping (Double?) -> Void) {
        let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
        Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).observe(.value) { (snapshot) in
            var totalStar: Double = 0
            if let value = snapshot.value as? [String: Int] {
                for (_, value) in value {
                    totalStar += Double(value)
                }
                completion(totalStar/Double(value.count))
            } else {
                completion(nil)
            }
        }
    }
    
    static private func removeBadString(_ cafeName: String) -> String {
        cafeName
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
    }
}
