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
    
    public func save<T: Object>(_ object: T, onError: ((Error?) -> Void)? = nil) {
        do {
            let realm = try self.realm()
            
            realm.writeAsync {
                realm.add(object, update: .modified)
            } onComplete: { error in
                onError?(error)
            }
            
        } catch {
            onError?(error)
        }
    }
    
    public func fetch<T: Object>(_ type: T.Type,
                                 sorted: (keyPath: String, ascending: Bool)? = nil,
                                 predicate: NSPredicate? = nil,
                                 completion: @escaping (Result<[T], Error>) -> Void) {
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
            completion(.success(array))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func fetch<T: Object>(_ type: T.Type,
                                 primaryKey: Any,
                                 completion: @escaping (Result<T?, Error>) -> Void) {
        do {
            let realm = try self.realm()
            let result = realm.object(ofType: type, forPrimaryKey: primaryKey)
            
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func update<T: Object>(_ object: T,
                                  with dictionary: [String: Any?],
                                  onError: ((Error?) -> Void)? = nil) {
        do {
            let realm = try self.realm()
            
            realm.writeAsync {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            } onComplete: { error in
                onError?(error)
            }
        } catch {
            onError?(error)
        }
    }
    
    public func delete<T: Object>(_ object: T,
                                  onError: ((Error?) -> Void)? = nil) {
        do {
            let realm = try self.realm()
            
            realm.writeAsync {
                realm.delete(object)
            } onComplete: { error in
                onError?(error)
            }
        } catch {
            onError?(error)
        }
    }
}
