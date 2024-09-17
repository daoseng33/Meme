//
//  MemeAPIServiceProtocol.swift
//  WebAPI
//
//  Created by DAO on 2024/9/3.
//

import Foundation
import RxSwift
import MemeData

public enum MemeAPIResponse<RandomMeme, RandomMemeError> {
    case success(RandomMeme)
    case failure(RandomMemeError)
}

public protocol MemeAPIServiceProtocol: BaseAPIServiceProtocol {
    func fetchRandomMeme(with keyword: String, mediaType: MemeMediaType, minRating: Int) -> Single<MemeAPIResponse<RandomMeme, RandomMemeError>>
}
