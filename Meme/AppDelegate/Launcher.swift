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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .secondarySystemBackground
        appearance.shadowColor = .clear
        appearance.setBackIndicatorImage(UIImage(systemSymbol: .chevronBackward), transitionMaskImage: UIImage(systemSymbol: .chevronBackward))
        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    private func setupAPIConfig() {
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
            APIConfiguration.apiKey = apiKey
        } else {
            print("API Key not found")
            // warning: you can replace your own humor api key here
            // https://humorapi.com/?ref=public_apis
        }
        
#if CI
        APIConfiguration.useMockData = true
#endif
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
#if CI
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = true
            config.inMemoryIdentifier = "MemeCI"
            Realm.Configuration.defaultConfiguration = config
#else
            let config = Realm.Configuration(
                schemaVersion: 3,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 3 {
                        migration.enumerateObjects(ofType: ImageData.className()) { oldObject, newObject in
                            newObject![Constant.Key.isFavorite] = false
                        }
                        migration.enumerateObjects(ofType: ImageData.className()) { oldObject, newObject in
                            newObject![Constant.Key.isFavorite] = false
                        }
                        migration.enumerateObjects(ofType: RandomJoke.className()) { oldObject, newObject in
                            newObject![Constant.Key.isFavorite] = false
                        }
                    }
                }
            )
            
            Realm.Configuration.defaultConfiguration = config
#endif
            
                do {
                    let _ = try Realm()
                } catch {
                    print("Error opening Realm: \(error)")
                }
        }
    }
}
