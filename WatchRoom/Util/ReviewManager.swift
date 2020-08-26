//
//  ReviewManager.swift
//  WatchRoom
//
//  Created by Bogdan on 23/8/20.
//

import Foundation
import StoreKit

enum ReviewManagerConfig: String {
    case ApplicationCountStatus = "app_count_status"
}

struct ReviewManager {
    static let shared = ReviewManager()
    
    func increaseAppOpenCount() {
        let userdefault = UserDefaults.standard
        
        let savedCount = userdefault.integer(forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
        if savedCount == 0 {
            userdefault.set(1, forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
        }
        else{
            userdefault.set(savedCount + 1, forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
        }
    }
    
    func checkAppOpenCountAndProvideReview() {
        let userdefault = UserDefaults.standard
        
        let appopencountvalue  = userdefault.integer(forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
        if appopencountvalue == 2 {
            requestReview()
        }
    }
    
    fileprivate func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
