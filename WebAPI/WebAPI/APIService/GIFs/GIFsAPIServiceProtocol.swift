//
//  GIFsAPIServiceProtocol.swift
//  WebAPI
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import MemeData
import RxSwift

public protocol GIFsAPIServiceProtocol: BaseAPIServiceProtocol {
    func fetchGifs(query: String, number: Int) -> Single<GIFs>
}
