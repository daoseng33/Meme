//
//  ImageData.swift
//  MemeData
//
//  Created by DAO on 2024/9/22.
//

import Foundation

public struct ImageData: Decodable {
    public let url: URL
    public let width: Int
    public let height: Int
    
    enum CodingKeys: CodingKey {
        case url
        case width
        case height
    }
    
    public enum ImageDataError: Error {
        case invalidURL(String)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urlString = try container.decode(String.self, forKey: .url)
        if let url = URL(string: urlString) {
            self.url = url
        } else {
            throw ImageDataError.invalidURL(urlString)
        }
        
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
    }
}
