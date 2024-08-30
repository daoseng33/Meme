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
    var baseURL: URL {
        var urlComponents = URLComponents(string: "https://api.humorapi.com")!
        let apiKey = Bundle.main.infoDictionary?["API_KEY"] as! String
        let queryItems = [
            URLQueryItem(name: "api-key", value: apiKey)
        ]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        
        return url
    }
}
