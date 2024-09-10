//
//  MemeAPIService.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import Foundation
import RxSwift
import MemeData
import RxMoya
import Moya

public struct MemeAPIService: MemeAPIServiceProtocol {
    var provider = MoyaProvider<MemeAPI>.default
    
    public init() {}
    
    public func fetchRandomMeme(with keyword: String, mediaType: MemeMediaType, minRating: Int) -> Single<RandomMeme> {
        return provider.rx
            .request(.randomMeme(keyword: keyword, mediaType: mediaType, minRating: minRating))
            .map(RandomMeme.self, using: JSONDecoder.default)
    }
}
