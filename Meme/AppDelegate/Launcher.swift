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
import SKPhotoBrowser

final class Launcher {
    @MainActor func setup() {
        setupAPIConfig()
        setupNavigationBar()
        handleGlobalError()
        setupIQKeyboardManager()
        setupSKPhotoBrowser()
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
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
            APIConfiguration.apiKey = apiKey
        } else {
            print("API Key not found")
            // warning: you can replace your own humor api key here
            // https://humorapi.com/?ref=public_apis
        }
    }
    
    @MainActor private func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    private func setupSKPhotoBrowser() {
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.backgroundColor = .black.withAlphaComponent(0.9)
        SKPhotoBrowserOptions.indicatorStyle = .medium
        SKPhotoBrowserOptions.displayCloseButton = false
        SKPhotoBrowserOptions.enableSingleTapDismiss = true
    }
}
