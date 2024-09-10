//
//  RandomMeme.swift
//  MemeData
//
//  Created by DAO on 2024/8/31.
//

import Foundation

public struct RandomMeme: Decodable {
    public let id: Int
    public let description: String
    public let url: URL?
    public let type: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(String.self, forKey: .type)

        let urlString = try container.decode(String.self, forKey: .url)
        self.url = URL(string: urlString)
    }

    private enum CodingKeys: String, CodingKey {
        case id, description, url, type
    }
}
