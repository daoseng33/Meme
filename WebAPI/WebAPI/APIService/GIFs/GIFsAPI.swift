//
//  GIFsAPI.swift
//  WebAPI
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import Moya

enum GIFsAPI {
    case searchGiFs(query: String, number: Int)
}

extension GIFsAPI: MemeTargetType {
    var path: String {
        switch self {
        case .searchGiFs:
            return "/gif/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchGiFs:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .searchGiFs(let query, let number):
            let parameters: [String: Any] = [
                "query": query,
                "number": number
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .searchGiFs:
            return nil
        }
    }
    
    var sampleData: Data {
        switch self {
        case .searchGiFs(let query, _):
            if query.isEmpty {
                return Utility.loadJSON(filename: "search_gifs_failure")
            } else {
                return Utility.loadJSON(filename: "search_gifs")
            }
            
        }
    }
}
