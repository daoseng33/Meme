//
//  AnalyticsManager.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() { }
    
    enum ContentType: String {
        case meme = "Meme"
        case joke = "Joke"
        case gif = "GIF"
    }
    
    func logShareEvent(contentType: ContentType, itemID: String) {
        Analytics.logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: contentType.rawValue,
            AnalyticsParameterItemID: itemID,
        ])
    }
}
