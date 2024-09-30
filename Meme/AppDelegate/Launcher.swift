//
//  Launcher.swift
//  Meme
//
//  Created by DAO on 2024/9/16.
//

import Foundation
import IQKeyboardManagerSwift
import HumorAPIService
import UIKit
import SFSafeSymbols

final class Launcher {
    @MainActor func setup() {
        setupIQKeyboardManager()
        setupAPIConfig()
        setupNavigationBar()
        handleGlobalError()
    }
    
    @MainActor private func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    private func handleGlobalError() {
        GlobalErrorHandler.shared.handleError()
    }
    
    private func setupNavigationBar() {
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.backgroundImage = UIImage(systemSymbol: .chevronBackward)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
    }
    
    private func setupAPIConfig() {
        // warning: you can replace your own humor api key here
        // https://humorapi.com/?ref=public_apis
        if let path = Bundle.main.path(forResource: "APIConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let apiKey = dict["API_KEY"] as? String {
            APIConfiguration.shared.APIKey = apiKey
        } else {
            print("You need to set your own API key in APIConfig.plist")
        }   
    }
}
