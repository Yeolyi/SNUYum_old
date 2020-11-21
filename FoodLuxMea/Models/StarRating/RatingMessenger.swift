//
//  RatingMessenger.swift
//  FoodLuxMea
//
//  Created by SEONG YEOL YI on 2020/11/20.
//

import Foundation
import Firebase

struct RatingMessenger {
    
    static func deleteMyRate(_ ratedMenuInfo: RatedMenuInfo) {
        isAlreadyRatedSingle(ratedMenuInfo) { isRated in
            if isRated {
                let id = appStatus.userID!
                let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
                Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).child(id).removeValue {_, _ in
                    let ref = Database.database().reference().child("users").child(id).child(ratedMenuInfo.date).child("ratingNum")
                    ref.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? Int {
                            ref.setValue(value-1)
                        }
                    }
                }
            } else {
                return
            }
        }
    }
    
    static func getMyRate(_ ratedMenuInfo: RatedMenuInfo, completion: @escaping (Int?) -> Void) {
        isAlreadyRatedSingle(ratedMenuInfo) { isRated in
            if isRated {
                let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
                if let id = appStatus.userID {
                    Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).child(id).observeSingleEvent(of: .value) { snapshot in
                        if let rate = snapshot.value as? Int {
                            completion(rate)
                        }
                    }
                }
            }
            completion(nil)
        }
    }
    static func isAlreadyRatedSingle(_ ratedMenuInfo: RatedMenuInfo, completion: @escaping (Bool) -> Void) {
        if let id = appStatus.userID {
            let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
            Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? [String: Int] {
                    if value.contains(where: {$0.key == id}) {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    static func isAlreadyRated(_ ratedMenuInfo: RatedMenuInfo, completion: @escaping (Bool) -> Void) {
        if let id = appStatus.userID {
            let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
            Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).observe(.value) { (snapshot) in
                if let value = snapshot.value as? [String: Int] {
                    if value.contains(where: {$0.key == id}) {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    static func checkRatingNumber(_ ratedMenuInfo: RatedMenuInfo, completion: @escaping (Bool) -> Void) {
        if let id = appStatus.userID {
            let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
            Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? [String: Int] {
                    if value.contains(where: {$0.key == id}) {
                        completion(true)
                        return
                    }
                }
                let ref = Database.database().reference().child("users").child(id).child(ratedMenuInfo.date).child("ratingNum")
                ref.observeSingleEvent(of: .value) { snapshot in
                    if let value = snapshot.value as? Int {
                        if value < 4 {
                            ref.setValue(value+1)
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } else {
                        ref.setValue(1)
                        completion(true)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
    static func sendIndividualRating(info ratedMenuInfo: RatedMenuInfo, star starValue: Int) {
        checkRatingNumber(ratedMenuInfo) { isRatingAvailable in
            if isRatingAvailable {
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
        }
    }
    
    static func getMenuRating(info ratedMenuInfo: RatedMenuInfo, completion: @escaping ((Double, Int)?) -> Void) {
        let filteredMenuName = removeBadString(ratedMenuInfo.menuName)
        Database.database().reference().child("stars").child(ratedMenuInfo.cafeName).child(ratedMenuInfo.date).child(filteredMenuName).observe(.value) { (snapshot) in
            var totalStar: Double = 0
            if let value = snapshot.value as? [String: Int] {
                for (_, value) in value {
                    totalStar += Double(value)
                }
                completion((totalStar/Double(value.count), value.count))
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
