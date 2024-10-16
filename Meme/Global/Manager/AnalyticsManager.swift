//
//  AnalyticsManager.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import Foundation
import FirebaseAnalytics
import AppTrackingTransparency

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() { }
}

// MARK: - Screen
extension AnalyticsManager {
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
}

// MARK: - GA Suggestion
extension AnalyticsManager {
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

// MARK: - Custom
extension AnalyticsManager {
    enum CustomEventName: String {
        case attStatus
        case favorite
        
        var value: String {
            return rawValue.camelCaseToSnakeCase()
        }
    }
    
    enum EventParameter: String {
        case isFavorite
        case status
        
        var value: String {
            return rawValue.camelCaseToSnakeCase()
        }
    }
    
    private func logCustomEvent(eventName: CustomEventName, parameters: [String: Any]?) {
        Analytics.logEvent(eventName.value, parameters: parameters)
    }
    
    func logAttStatusEvent(attStatus: ATTrackingManager.AuthorizationStatus) {
        logCustomEvent(eventName: .attStatus, parameters: [
            EventParameter.status.value: attStatus.statusString,
        ])
    }
    
    func logFavoriteEvent(isFavorite: Bool) {
        logCustomEvent(eventName: .favorite, parameters: [
            EventParameter.isFavorite.value: isFavorite ? "true" : "false",
        ])
    }
}

// MARK: - Select Content
extension AnalyticsManager {
    func logSelectConentEvent(parameters: [String: Any]?) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: parameters)
    }
}
