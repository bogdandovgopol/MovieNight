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
    case ApplicationReviewRequested = "app_review_requested"
}

struct ReviewManager {
    static let shared = ReviewManager()
    
    func increaseAppOpenCount() {
        let userdefault = UserDefaults.standard
        let didRequestedReview = userdefault.bool(forKey: ReviewManagerConfig.ApplicationReviewRequested.rawValue)
        
        if didRequestedReview == false {
            let savedCount = userdefault.integer(forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
            if savedCount == 0 {
                userdefault.set(1, forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
            }
            else{
                userdefault.set(savedCount + 1, forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
            }
        }
    }
    
    func checkAppOpenCountAndProvideReview() {
        let userdefault = UserDefaults.standard
        
        let appopencountvalue  = userdefault.integer(forKey: ReviewManagerConfig.ApplicationCountStatus.rawValue)
        let didRequestedReview = userdefault.bool(forKey: ReviewManagerConfig.ApplicationReviewRequested.rawValue)
        
        if didRequestedReview == false {
            if appopencountvalue >= 2 {
                requestReview()
                userdefault.set(true, forKey: ReviewManagerConfig.ApplicationReviewRequested.rawValue)
            }
        }
    }
    
    fileprivate func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
