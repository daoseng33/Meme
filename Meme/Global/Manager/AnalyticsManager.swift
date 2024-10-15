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
    
    enum ScreenName: String {
        case homepage = "Home Page"
        case history = "History Page"
        case favorite = "Favorite Page"
        case settings = "Settings Page"
        case randomMeme = "RandomMeme Page"
        case randomJoke = "RandomJoke Page"
        case gifs = "GIFs Page"
        case appearance = "Appearance Page"
    }
    
    func logScreenView(screenName: ScreenName) {
        let parameters: [String: Any] = [AnalyticsParameterScreenName: screenName.rawValue]
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }
    
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
