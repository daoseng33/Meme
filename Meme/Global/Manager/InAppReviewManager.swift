//
//  InAppReviewManager.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import UIKit
import StoreKit

final class InAppReviewManager {
    static let shared = InAppReviewManager()
    
    private init() { }
    
    func requestReview() {
        #if RELEASE
        if let scene = UIApplication.activeScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        #endif
    }
}
