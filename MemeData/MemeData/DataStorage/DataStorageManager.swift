//
//  DataStorage.swift
//  MemeData
//
//  Created by DAO on 2024/9/25.
//

import Foundation
import RealmSwift

final public class DataStorageManager {
    // MARK: - Properties
    static public let shared = DataStorageManager()
    
    // MARK: - Init
    private init() {}
    
    private func realm(for configuration: Realm.Configuration = .defaultConfiguration) throws -> Realm {
        return try Realm(configuration: configuration)
    }
    
    public func save<T: Object>(_ object: T, onError: ((Error?) -> Void)? = nil) {
        DispatchQueue.main.async {
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
    }
    
    public func fetch<T: Object>(_ type: T.Type, completion: @escaping (Result<Array<T>, Error>) -> Void){
        DispatchQueue.main.async {
            do {
                let realm = try self.realm()
                let results = realm.objects(type)
                let array = Array(results)
                completion(.success(array))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func update<T: Object>(_ object: T, with dictionary: [String: Any?], onError: ((Error?) -> Void)? = nil) {
        DispatchQueue.main.async {
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
    }
    
    public func delete<T: Object>(_ object: T, onError: ((Error?) -> Void)? = nil) {
        DispatchQueue.main.async {
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
}
