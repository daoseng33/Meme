//
//  KeychainHandler.swift
//  Meme
//
//  Created by DAO on 2024/10/17.
//

import Security
import Foundation

final class KeychainHandler {
    enum Key: String {
        case apiRequestCount
        case isSubscribed
    }
    
    func save(key: Key, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key.rawValue,
            kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: Key) -> Data? {
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
    
    func saveInt(_ integer: Int, forKey key: Key) -> OSStatus {
        var intValue = integer
        let data = Data(bytes: &intValue, count: MemoryLayout<Int>.size)
        
        return save(key: key, data: data)
    }
        
    func loadInt(forKey key: Key) -> Int? {
        guard let data = load(key: key) else { return nil }
        
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }
    
    func saveBool(_ bool: Bool, forKey key: Key) -> OSStatus {
        var boolValue = bool
        let data = Data(bytes: &boolValue, count: MemoryLayout<Bool>.size)
        
        return save(key: key, data: data)
    }
    
    func loadBool(forKey key: Key) -> Bool? {
        guard let data = load(key: key) else { return nil }
        
        return data.withUnsafeBytes { $0.load(as: Bool.self) }
    }
}
