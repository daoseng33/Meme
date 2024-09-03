//
//  MemeTargetType.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import Foundation
import Moya

protocol MemeTargetType: TargetType {}

extension MemeTargetType {
    public var baseURL: URL {
        var urlComponents = URLComponents(string: "https://api.humorapi.com")!
        //TODO: use local env var
        let apiKey = "c699117cbef449239496978726d4a1e3"
        let queryItems = [
            URLQueryItem(name: "api-key", value: apiKey)
        ]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        
        return url
    }
}
