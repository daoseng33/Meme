//
//  KeychainManager.swift
//  Meme
//
//  Created by DAO on 2024/10/17.
//

import Security
import Foundation

class KeychainManager {
    enum Key: String {
        case apiRequestCount
    }
    
    static func save(key: Key, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key.rawValue,
            kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: Key) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    static func saveInt(_ integer: inout Int, forKey key: Key) -> OSStatus {
        let data = Data(bytes: &integer, count: MemoryLayout<Int>.size)
        
        return save(key: key, data: data)
    }
        
    static func loadInt(forKey key: Key) -> Int? {
        guard let data = load(key: key) else { return nil }
        
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }
}
