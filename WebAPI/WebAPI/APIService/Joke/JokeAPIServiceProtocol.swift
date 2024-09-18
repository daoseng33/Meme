//
//  JokeAPIServiceProtocol.swift
//  WebAPI
//
//  Created by DAO on 2024/9/18.
//

import Foundation
import RxSwift
import MemeData

public enum JokeAPIResponse<RandomJoke, MemeError> {
    case success(RandomJoke)
    case failure(MemeError)
}

protocol JokeAPIServiceProtocol: BaseAPIServiceProtocol {
    func fetchRandomJoke(tags: String, excludedTags: String, minRating: Int, maxLength: Int) -> Single<JokeAPIResponse<RandomJoke, MemeError>>
}
