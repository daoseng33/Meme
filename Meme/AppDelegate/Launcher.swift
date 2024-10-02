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
import RealmSwift

final class Launcher {
    func launch() {
        setupAPIConfig()
        setupNavigationBar()
        handleGlobalError()
        setupIQKeyboardManager()
        setupSKPhotoBrowser()
        setupDatabaseMigration()
    }
    
    private func handleGlobalError() {
        GlobalErrorHandleManager.shared.handleError()
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
    
    private func setupIQKeyboardManager() {
        DispatchQueue.main.async {
            IQKeyboardManager.shared.enable = true
            IQKeyboardManager.shared.resignOnTouchOutside = true
        }
    }
    
    private func setupSKPhotoBrowser() {
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.backgroundColor = .black.withAlphaComponent(0.9)
        SKPhotoBrowserOptions.indicatorStyle = .medium
        SKPhotoBrowserOptions.displayCloseButton = false
        SKPhotoBrowserOptions.enableSingleTapDismiss = true
    }
    
    private func setupDatabaseMigration() {
        DispatchQueue.main.async {
            let config = Realm.Configuration(
                    schemaVersion: 2,
                    migrationBlock: { migration, oldSchemaVersion in
                        if oldSchemaVersion < 2 {
                            migration.enumerateObjects(ofType: ImageData.className()) { oldObject, newObject in
                                newObject!["createdAt"] = Date()
                            }
                            migration.enumerateObjects(ofType: RandomJoke.className()) { oldObject, newObject in
                                newObject!["createdAt"] = Date()
                            }
                        }
                    }
                )
                
                Realm.Configuration.defaultConfiguration = config
                
                do {
                    let _ = try Realm()
                } catch {
                    print("Error opening Realm: \(error)")
                }
        }
    }
}
