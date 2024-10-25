//
//  InAppReviewHandler.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import UIKit
import StoreKit

struct InAppReviewHandler {
    private var shouldRequestReview: Bool {
        let reachPositiveEngageBoundary = UserDefaults.standard.integer(forKey: UserDefaults.Key.positiveEngageCount.rawValue) >= Constant.Review.positiveEngageBoundary
        let reachGenerateContentBoundary = UserDefaults.standard.integer(forKey: UserDefaults.Key.generateConentCount.rawValue) >= Constant.Review.generateContentBoundary
        return reachPositiveEngageBoundary || reachGenerateContentBoundary
    }
    
    func increasePositiveEngageCount() {
        let positiveEngageCount = UserDefaults.standard.integer(forKey: UserDefaults.Key.positiveEngageCount.rawValue)
        UserDefaults.standard.set(positiveEngageCount + 1, forKey: UserDefaults.Key.positiveEngageCount.rawValue)
    }
    
    func increaseGenerateContentCount() {
        let generateContentCount = UserDefaults.standard.integer(forKey: UserDefaults.Key.generateConentCount.rawValue)
        UserDefaults.standard.set(generateContentCount + 1, forKey: UserDefaults.Key.generateConentCount.rawValue)
    }
    
    func requestReview() {
#if RELEASE
        if let scene = UIApplication.activeScene, shouldRequestReview {
            UserDefaults.standard.set(0, forKey: UserDefaults.Key.positiveEngageCount.rawValue)
            UserDefaults.standard.set(0, forKey: UserDefaults.Key.generateConentCount.rawValue)
            SKStoreReviewController.requestReview(in: scene)
        }
#endif
    }
}
