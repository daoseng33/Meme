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
        
        // warning: you can replace your own humor api key here
        // https://humorapi.com/?ref=public_apis
        if let path = Bundle(identifier: "com.likeabossapp.WebAPI")?.path(forResource: "APIConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let apiKey = dict["API_KEY"] as? String {
            let queryItems = [
                URLQueryItem(name: "api-key", value: apiKey)
            ]
            urlComponents.queryItems = queryItems
        }
        
        let url = urlComponents.url!
        
        return url
    }
}
