//
//  GIFsAPIService.swift
//  WebAPI
//
//  Created by DAO on 2024/9/22.
//

import Foundation
import RxSwift
import MemeData
import Moya
import RxMoya

public struct GIFsAPIService: GIFsAPIServiceProtocol {
    private let provider: MoyaProvider<GIFsAPI>
    
    public init(useMockData: Bool = false) {
        provider = useMockData ? MoyaProvider<GIFsAPI>.stub : MoyaProvider<GIFsAPI>.default
    }
    
    public func fetchGifs(query: String, number: Int) -> Single<GIFs> {
        provider.rx.request(.searchGiFs(query: query, number: number))
            .map(GIFs.self, using: JSONDecoder.default)
    }
}
