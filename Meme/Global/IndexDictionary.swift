//
//  IndexDictionary.swift
//  Meme
//
//  Created by DAO on 2024/10/4.
//

import Foundation

struct IndexedDictionary<Key: Hashable, Value> {
    private var array: [(Key, Value)] = []
    private var dict: [Key: Int] = [:]
    var keys: Dictionary<Key, Int>.Keys {
        return dict.keys
    }
    
    mutating func updateValue(_ value: Value, forKey key: Key) {
        if let index = dict[key] {
            array[index] = (key, value)
        } else {
            array.append((key, value))
            dict[key] = array.count - 1
        }
    }
    
    func index(forKey key: Key) -> Int? {
        return dict[key]
    }
    
    subscript(key: Key) -> Value? {
        get {
            guard let index = dict[key] else { return nil }
            return array[index].1
        }
        set {
            if let newValue = newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    mutating func removeValue(forKey key: Key) {
        guard let index = dict[key] else { return }
        array.remove(at: index)
        dict[key] = nil
        
        // Update indices for all elements after the removed one
        for i in index..<array.count {
            dict[array[i].0] = i
        }
    }
    
    mutating func reset() {
        array.removeAll()
        dict.removeAll()
    }
}
