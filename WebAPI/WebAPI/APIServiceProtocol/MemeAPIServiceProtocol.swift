//
//  MemeAPIServiceProtocol.swift
//  WebAPI
//
//  Created by DAO on 2024/9/3.
//

import Foundation
import RxSwift
import MemeData

public protocol MemeAPIServiceProtocol {
    func fetchRandomMeme(with keyword: String, mediaType: MemeMediaType, minRating: Int) -> Single<RandomMeme>
}
