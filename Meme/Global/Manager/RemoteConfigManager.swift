//
//  RemoteConfigManager.swift
//  Meme
//
//  Created by DAO on 2024/10/17.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseCrashlytics

final class RemoteConfigManager {
    // MARK: - Properties
    static let shared = RemoteConfigManager()
    private let remoteConfig: RemoteConfig
    
    enum Key: String {
        case apiRequestLimit = "API_REQUEST_LIMIT"
    }
    
    // MARK: - Init
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        setupRemoteConfig()
    }
    
    // MARK: - Setup
    func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        #if RELEASE
        settings.minimumFetchInterval = 43200 // 12 hours
        #else
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
    }
    
    func fetchAndActivate(completion: @escaping (Error?) -> Void) {
        remoteConfig.fetchAndActivate { (status, error) in
            if let error = error {
                print("Error fetching remote values: \(error)")
                Crashlytics.crashlytics().record(error: error)
                completion(error)
            } else {
                print("Retrieved values from the server!")
                completion(nil)
            }
        }
    }
    
    // MARK: - Get data
    func getString(forKey key: Key) -> String {
        return remoteConfig[key.rawValue].stringValue
    }
    
    func getNumber(forKey key: Key) -> NSNumber {
        return remoteConfig[key.rawValue].numberValue
    }
    
    func getBool(forKey key: Key) -> Bool {
        return remoteConfig[key.rawValue].boolValue
    }
    
    func getData(forKey key: Key) -> Data {
        return remoteConfig[key.rawValue].dataValue
    }
}
