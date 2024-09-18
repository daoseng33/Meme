//
//  JokeAPI.swift
//  WebAPI
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import Moya

public enum JokeAPI {
    case randomJoke(tags: String, excludeTags: String, minRating: Int, maxLength: Int)
}

extension JokeAPI: MemeTargetType {
    public var path: String {
        switch self {
        case .randomJoke:
            return "jokes/random"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .randomJoke:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .randomJoke(let tags, let excludeTags, let minRating, let maxLength):
            return .requestParameters(parameters: [
                "include-tags": tags,
                "exclude-tags": excludeTags,
                "min-rating": minRating,
                "max-length": maxLength
            ], encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .randomJoke:
            return nil
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .randomJoke(let tages, _, _ , _):
            if tages == "cats" {
                return Utility.loadJSON(filename: "random_joke_error")
            } else {
                return Utility.loadJSON(filename: "random_joke")
            }
            
        }
    }
}
