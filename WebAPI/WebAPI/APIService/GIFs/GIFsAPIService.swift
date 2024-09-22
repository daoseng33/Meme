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
    public let useMockData: Bool
    
    public init(useMockData: Bool = false) {
        self.useMockData = useMockData
        provider = useMockData ? MoyaProvider<GIFsAPI>.default : MoyaProvider<GIFsAPI>.stub
    }
    
    public func fetchGifs(query: String, number: Int) -> Single<GIFs> {
        provider.rx.request(.searchGiFs(query: query, number: number))
            .map(GIFs.self, using: JSONDecoder.default)
    }
}
