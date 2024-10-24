//
//  Constant.swift
//  Meme
//
//  Created by DAO on 2024/9/18.
//

import Foundation

enum Constant {
    enum UI {
        /// 4
        static let spacing1: CGFloat = 4
        
        /// 8
        static let spacing2: CGFloat = 8
        
        /// 12
        static let spacing3: CGFloat = 12
        
        /// 16
        static let spacing4: CGFloat = 16
        
        /// 20
        static let spacing5: CGFloat = 20
    }
    
    enum Ad {
        static let adBannerHeight: CGFloat = 70
    }
    
    enum Review {
        static let positiveEngageBoundary = 3
        static let generateContentBoundary = 10
    }
    
    enum Key {
        static let isFavorite = "isFavorite"
        static let titleTextColor = "titleTextColor"
    }
    
    enum DEBUG {
        static let gadBannerUnitId = "ca-app-pub-3940256099942544/2435281174"
        static let gadFullPageUnitId = "ca-app-pub-3940256099942544/4411468910"
    }
}
