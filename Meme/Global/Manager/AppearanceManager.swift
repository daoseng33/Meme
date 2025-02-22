//
//  AppearanceManager.swift
//  Meme
//
//  Created by DAO on 2024/10/11.
//

import UIKit

enum AppearanceStyle: String, CaseIterable {
    case system = "Follow System"
    case light = "Light Mode"
    case dark = "Dark Mode"
}

final class AppearanceManager {
    static let shared = AppearanceManager()
    
    private init() { }
    
    func changeAppearance(_ style: AppearanceStyle) {
        let windowScene = UIApplication.activeScene
        
        let windows = windowScene?.windows ?? []
 
        let interfaceStyle: UIUserInterfaceStyle
        switch style {
        case .light:
            interfaceStyle = .light
        case .dark:
            interfaceStyle = .dark
        case .system:
            interfaceStyle = .unspecified
        }
        
        windows.forEach { $0.overrideUserInterfaceStyle = interfaceStyle }
    }
}

