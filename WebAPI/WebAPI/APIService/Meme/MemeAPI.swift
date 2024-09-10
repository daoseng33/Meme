//
//  MemeAPI.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import Foundation
import Moya

public enum MemeMediaType: String {
    case image
    case video
}

public enum MemeAPI {
    case randomMeme(keyword: String, mediaType: MemeMediaType, minRating: Int)
}

extension MemeAPI: MemeTargetType {
    public var path: String {
        switch self {
        case .randomMeme:
            return "/memes/random"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .randomMeme:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .randomMeme(let keyword, let mediaType, let minRating):
            return .requestParameters(parameters: [
                "keywords": keyword,
                "media-type": mediaType.rawValue,
                "min-rating": minRating
            ], encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .randomMeme:
            return nil
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .randomMeme(_, let mediaType, _):
            switch mediaType {
            case .image:
                return Utility.loadJSON(filename: "memes_random_image")
            case .video:
                return Utility.loadJSON(filename: "memes_random_video")
            }
            
        }
    }
}
