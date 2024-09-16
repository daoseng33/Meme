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
    
    public func fetchRandomMeme(with keyword: String, mediaType: MemeMediaType, minRating: Int) -> Single<MemeAPIResponse<RandomMeme, RandomMemeError>> {
        return provider.rx
            .request(.randomMeme(keyword: keyword, mediaType: mediaType, minRating: minRating))
            .flatMap({ response in
                do {
                    let decode = try response.map(RandomMeme.self, using: JSONDecoder.default)
                    return .just(.success(decode))
                } catch {
                    do {
                        let decode = try response.map(RandomMemeError.self, using: JSONDecoder.default)
                        return .just(.failure(decode))
                    } catch {
                        return .error(error)
                    }
                }
            })
    }
}
