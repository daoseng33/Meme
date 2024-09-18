//
//  MemeAPIServiceProtocol.swift
//  WebAPI
//
//  Created by DAO on 2024/9/3.
//

import Foundation
import RxSwift
import MemeData

public enum MemeAPIResponse<RandomMeme, MemeError> {
    case success(RandomMeme)
    case failure(MemeError)
}

public protocol MemeAPIServiceProtocol: BaseAPIServiceProtocol {
    func fetchRandomMeme(with keyword: String, mediaType: MemeMediaType, minRating: Int) -> Single<MemeAPIResponse<RandomMeme, MemeError>>
}
