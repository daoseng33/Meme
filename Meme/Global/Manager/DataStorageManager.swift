//
//  DataStorageManager.swift
//  Meme
//
//  Created by DAO on 2024/10/2.
//

import Foundation
import RealmSwift

@MainActor
final public class DataStorageManager {
    // MARK: - Properties
    static public let shared = DataStorageManager()
    
    // MARK: - Init
    private init() {}
    
    private func realm(for configuration: Realm.Configuration = .defaultConfiguration) throws -> Realm {
        return try Realm(configuration: configuration)
    }
    
    public func save<T: Object>(_ object: T) {
        do {
            let realm = try self.realm()
            try realm.write {
                realm.add(object, update: .modified)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func saveAsync<T: Object>(_ object: T, onComplete: ((Error?) -> Void)? = nil) {
        do {
            let realm = try self.realm()
            realm.writeAsync {
                realm.add(object, update: .modified)
            } onComplete: { error in
                if let error = error {
                    print(error.localizedDescription)
                }

                onComplete?(error)
            }
            
        } catch {
            onComplete?(error)
        }
    }
    
    public func fetch<T: Object>(_ type: T.Type,
                                 sorted: (keyPath: String, ascending: Bool)? = nil,
                                 predicate: NSPredicate? = nil) -> [T] {
        do {
            let realm = try self.realm()
            var results = realm.objects(type)
            
            if let predicate = predicate {
                results = results.filter(predicate)
            }
            
            if let sorted = sorted {
                results = results.sorted(byKeyPath: sorted.keyPath, ascending: sorted.ascending)
            }
            
            let array = Array(results)
            return array
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    public func fetch<T: Object>(_ type: T.Type,
                                 primaryKey: Any) -> T? {
        do {
            let realm = try self.realm()
            let result = realm.object(ofType: type, forPrimaryKey: primaryKey)
            
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func update<T: Object>(_ object: T,
                                  with dictionary: [String: Any?]) {
        do {
            let realm = try self.realm()
            
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateAsync<T: Object>(_ object: T,
                                  with dictionary: [String: Any?],
                                  onComplete: ((Error?) -> Void)? = nil) {
        do {
            let realm = try self.realm()
            
            realm.writeAsync {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            } onComplete: { error in
                if let error {
                    print(error.localizedDescription)
                }
                
                onComplete?(error)
            }
        } catch {
            print(error.localizedDescription)
            onComplete?(error)
        }
    }
    
    public func delete<T: Object>(_ object: T) {
        do {
            let realm = try self.realm()
            
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteAsync<T: Object>(_ object: T,
                                  onComplete: ((Error?) -> Void)? = nil) {
        do {
            let realm = try self.realm()
            
            realm.writeAsync {
                realm.delete(object)
            } onComplete: { error in
                if let error {
                    print(error.localizedDescription)
                }
                
                onComplete?(error)
            }
        } catch {
            print(error.localizedDescription)
            onComplete?(error)
        }
    }
    
    public func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
