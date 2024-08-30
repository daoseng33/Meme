//
//  MemeWebService.swift
//  Meme
//
//  Created by DAO on 2024/8/30.
//

import Foundation
import Moya
import RxSwift

class MemeWebService {
  static let shared = MemeWebService()
  
  func request<T: MemeTargetType, U: Decodable>(provider: MoyaProvider<T>, targetType: T, mappingType: U.Type) -> Single<U> {
    return provider.rx
      .request(targetType)
      .map(mappingType, using: JSONDecoder.default)
      .do(onError: { error in
        // TODO: Send error log to Crashlytics
        // TODO: Handle global error here(e.g. Force update, user token expired)
      })
  }
}

