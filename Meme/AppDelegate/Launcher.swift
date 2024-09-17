//
//  Launcher.swift
//  Meme
//
//  Created by DAO on 2024/9/16.
//

import Foundation
import IQKeyboardManagerSwift

final class Launcher {
    @MainActor func setup() {
        setupIQKeyboardManager()
    }
    
    @MainActor private func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
}
