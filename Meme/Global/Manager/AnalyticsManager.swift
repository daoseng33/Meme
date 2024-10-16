//
//  AnalyticsManager.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import Foundation
import FirebaseAnalytics
import AppTrackingTransparency
import HumorAPIService

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() { }
}

// MARK: - General
extension AnalyticsManager {
    enum EventName: String {
        case attStatus
        case favorite
        case generateContentClick
        case jokeCategorySelect
        case menuDateSelect
        case menuCategorySelect
        
        var value: String {
            switch self {
                // Custom event
            case .attStatus, .favorite:
                return rawValue.camelCaseToSnakeCase()
                // Others
            case _:
                return rawValue.camelCaseToTitleCase()
            }
        }
    }
    
    enum EventParameter: String {
        case isFavorite
        case status
        case keyword
        
        var value: String {
            return rawValue.camelCaseToSnakeCase()
        }
    }
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
    private func logCustomEvent(eventName: EventName, parameters: [String: Any]?) {
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
    private func logSelectConentEvent(parameters: [String: Any]?) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: parameters)
    }
    
    func logGenerateContentClickEvent(type: ContentType, keyword: String? = nil) {
        logSelectConentEvent(parameters: [
            AnalyticsParameterContent: EventName.generateContentClick.value,
            AnalyticsParameterContentType: type.rawValue,
            EventParameter.keyword.rawValue: keyword ?? ""
        ])
    }
    
    func logSelectJokeCategoryEvent(category: JokeCategory) {
        logSelectConentEvent(parameters: [
            AnalyticsParameterContent: EventName.jokeCategorySelect.value,
            AnalyticsParameterContentType: category.rawValue
        ])
    }
    
    func logSelectDateTypeEvent(dateType: MenuDate) {
        logSelectConentEvent(parameters: [
            AnalyticsParameterContent: EventName.menuDateSelect.value,
            AnalyticsParameterContentType: dateType.rawValue
        ])
    }
    
    func logSelectCategoryTypeEvent(categoryType: MenuCategory) {
        logSelectConentEvent(parameters: [
            AnalyticsParameterContent: EventName.menuCategorySelect.value,
            AnalyticsParameterContentType: categoryType.rawValue
        ])
    }
}
