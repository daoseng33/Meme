//
//  RandomMeme.swift
//  MemeData
//
//  Created by DAO on 2024/8/31.
//

import Foundation
import RealmSwift

public final class RandomMeme: Object, Decodable {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var memeDescription: String
    public var url: URL? {
        URL(string: urlString)
    }
    @Persisted public var urlString: String
    @Persisted public var type: String
    @Persisted public var createdAt: Date = Date()
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        memeDescription = try container.decode(String.self, forKey: .description)
        type = try container.decode(String.self, forKey: .type)

        let urlString = try container.decode(String.self, forKey: .url)
        self.urlString = urlString
    }
    
    public override init() {
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case id, description, url, type
    }
}
